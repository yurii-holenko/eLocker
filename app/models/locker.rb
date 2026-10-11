class Locker < ApplicationRecord
  include AASM

  # Events a user may trigger from the UI. `block` and `unblock` are fired by
  # the system only.
  USER_EVENTS = %w[open close fail_attempt].freeze

  class InvalidAction < StandardError; end

  belongs_to :team
  has_one :company, through: :team
  has_many :actions, class_name: "LockerAction", inverse_of: :locker, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :location, presence: true

  # The single place that decides which lockers a user may see or operate.
  # Every controller loads lockers through this scope.
  scope :accessible_to, ->(user) { user.support? ? all : where(team_id: user.team_id) }
  # Case-insensitive match on the locker's name or location.
  scope :search, ->(text) {
    pattern = "%#{sanitize_sql_like(text)}%"

    where("lockers.name ILIKE :pattern OR lockers.location ILIKE :pattern", pattern: pattern)
  }

  # Every allowed state change is listed here; anything else raises.
  # Guards receive the acting user. `requires_lock` takes a row lock while an
  # event fires, so simultaneous requests are handled one after another.
  aasm column: :state, whiny_persistence: true, requires_lock: true, create_scopes: false do
    state :closed, initial: true
    state :open
    state :blocked, before_enter: :start_block, exit: :clear_block

    event :open do
      transitions from: :closed, to: :open
      # A blocked locker opens only for support, or for anyone once the block has run out.
      transitions from: :blocked, to: :open, guard: :may_bypass_block?
    end

    event :close do
      transitions from: :open, to: :closed
    end

    # A wrong access code. Support engineers open lockers without a code.
    event :fail_attempt do
      transitions from: :closed, to: :closed, guard: :enters_code?
    end

    event :block do
      transitions from: :closed, to: :blocked
    end

    event :unblock do
      transitions from: :blocked, to: :closed, guard: :block_expired?
    end
  end

  # Fires a user event and records it, atomically. Too many wrong codes from
  # the same user block the locker for the time set by the company.
  def perform!(kind, by:)
    raise InvalidAction, I18n.t("lockers.errors.unknown_action") unless USER_EVENTS.include?(kind)

    transaction do
      fire_and_log!(kind, by)

      if kind == "fail_attempt" && failed_attempts_left_for(by).zero?
        # Blocking is the system's reaction to the wrong codes, not something
        # the user did, so it is logged without a user, like the unblock.
        fire_and_log!("block", nil)
        UnblockLockerJob.set(wait_until: blocked_until).perform_later(self)
      end
    end
  rescue AASM::InvalidTransition
    raise InvalidAction, I18n.t("lockers.errors.#{kind}.#{state}", name: name)
  end

  # Called by UnblockLockerJob. Does nothing if the locker was opened by
  # support in the meantime or has been blocked again since.
  def unblock_if_expired!
    with_lock { fire_and_log!("unblock", nil) if may_unblock? }
  end

  def available_events_for(user)
    USER_EVENTS.select { |event| aasm.may_fire_event?(event.to_sym, user) }
  end

  def failed_attempts_left_for(user)
    [ company.settings.max_failed_attempts - failed_attempts_by(user), 0 ].max
  end

  def block_expired?
    blocked? && blocked_until <= Time.current
  end

  def blocked_minutes_left
    ((blocked_until - Time.current) / 60).ceil.clamp(0..) if blocked?
  end

  private

  def fire_and_log!(event, user)
    aasm.fire!(event.to_sym, user)
    actions.create!(user: user, kind: event)
  end

  # The action log is the source of truth: wrong codes by this user since they
  # last opened the locker, or since it was last blocked.
  def failed_attempts_by(user)
    counted_from = actions.where(kind: "block").or(actions.where(kind: "open", user: user)).maximum(:id) || 0

    actions.where(kind: "fail_attempt", user: user).where("id > ?", counted_from).count
  end

  def may_bypass_block?(user)
    user.support? || block_expired?
  end

  def enters_code?(user)
    user.employee?
  end

  def start_block
    self.blocked_until = company.settings.block_duration_minutes.minutes.from_now
  end

  def clear_block
    self.blocked_until = nil
  end
end
