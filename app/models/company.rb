class Company < ApplicationRecord
  has_many :teams, dependent: :restrict_with_exception
  has_one :settings, class_name: "CompanySetting", dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # Always answers with settings: the saved row, or the defaults.
  def settings
    super || build_settings
  end
end
