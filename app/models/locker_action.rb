# One row per state machine event fired on a locker (see Locker).
class LockerAction < ApplicationRecord
  KINDS = %w[open close fail_attempt block unblock].freeze

  belongs_to :locker
  # Empty when the system did it, e.g. the timed unblock.
  belongs_to :user, optional: true

  validates :kind, inclusion: { in: KINDS }
end
