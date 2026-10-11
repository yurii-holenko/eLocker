# One row per state machine event fired on a locker (see Locker).
class LockerAction < ApplicationRecord
  KINDS = %w[open close fail_attempt block unblock].freeze

  belongs_to :locker
  # Empty when the system did it: blocking a locker and the timed unblock.
  belongs_to :user, optional: true

  validates :kind, inclusion: { in: KINDS }

  # Actions on the lockers the user may see: the same rule as for lockers.
  scope :accessible_to, ->(user) { where(locker_id: Locker.accessible_to(user).select(:id)) }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  # Case-insensitive match on the locker's name or the user's name.
  scope :search, ->(text) {
    pattern = "%#{sanitize_sql_like(text)}%"

    joins(:locker).left_joins(:user).where("lockers.name ILIKE :pattern OR users.name ILIKE :pattern", pattern: pattern)
  }
end
