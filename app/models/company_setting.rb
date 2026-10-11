# Rules a company configures for itself. One row per company; a company
# without a row uses the column defaults (see Company#settings).
class CompanySetting < ApplicationRecord
  belongs_to :company

  validates :company_id, uniqueness: true
  # How many wrong access codes one user may enter on a locker before it is
  # blocked, and for how long it stays blocked.
  validates :max_failed_attempts, :block_duration_minutes, numericality: { only_integer: true, greater_than: 0 }
end
