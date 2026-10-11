class User < ApplicationRecord
  belongs_to :team, optional: true
  has_one :company, through: :team

  # Stored as a string, so the column stays readable in the database.
  enum :role, { employee: "employee", support: "support" }, validate: true

  validates :name, presence: true
  validates :team, presence: true, if: :employee?
  validates :team, absence: true, if: :support?
end
