class CreateCompaniesTeamsAndUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :teams do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
      t.index [ :company_id, :name ], unique: true
    end

    create_table :users do |t|
      t.string :name, null: false
      t.string :role, null: false, default: "employee"
      # Employees belong to exactly one team; eLocker support engineers to none.
      t.references :team, foreign_key: true
      t.timestamps
      t.check_constraint "(role = 'employee') = (team_id IS NOT NULL)", name: "users_team_matches_role"
    end
  end
end
