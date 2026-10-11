class Team < ApplicationRecord
  belongs_to :company
  has_many :users, dependent: :restrict_with_exception
  has_many :lockers, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :company_id }
end
