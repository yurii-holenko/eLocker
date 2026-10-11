class AddLockerBlocking < ActiveRecord::Migration[7.2]
  def change
    # Per-company rules for blocking a locker after wrong access codes.
    add_column :companies, :max_failed_attempts, :integer, null: false, default: 3
    add_column :companies, :block_duration_minutes, :integer, null: false, default: 10
    add_check_constraint :companies, "max_failed_attempts > 0", name: "companies_max_failed_attempts_positive"
    add_check_constraint :companies, "block_duration_minutes > 0", name: "companies_block_duration_positive"

    add_column :lockers, :blocked_until, :datetime
    remove_check_constraint :lockers, "state IN ('open', 'closed')", name: "lockers_state_valid"
    add_check_constraint :lockers, "state IN ('open', 'closed', 'blocked')", name: "lockers_state_valid"
    add_check_constraint :lockers, "(state = 'blocked') = (blocked_until IS NOT NULL)", name: "lockers_blocked_until_matches_state"

    # The timed unblock is done by the system, not by a user.
    change_column_null :locker_actions, :user_id, true
    remove_check_constraint :locker_actions, "kind IN ('open', 'close')", name: "locker_actions_kind_valid"
    add_check_constraint :locker_actions, "kind IN ('open', 'close', 'fail_attempt', 'block', 'unblock')",
      name: "locker_actions_kind_valid"
  end
end
