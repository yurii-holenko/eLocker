class CreateLockersAndLockerActions < ActiveRecord::Migration[7.2]
  def change
    create_table :lockers do |t|
      # The owning company is derived from the team, so a locker can never
      # point at a team of another company.
      t.references :team, null: false, foreign_key: true
      t.string :name, null: false, index: { unique: true }
      t.string :location, null: false
      t.string :state, null: false, default: "closed"
      t.timestamps
      t.check_constraint "state IN ('open', 'closed')", name: "lockers_state_valid"
    end

    create_table :locker_actions do |t|
      t.references :locker, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.datetime :created_at, null: false
      t.index [ :locker_id, :created_at ]
      t.check_constraint "kind IN ('open', 'close')", name: "locker_actions_kind_valid"
    end
  end
end
