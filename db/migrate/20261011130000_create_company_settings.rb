# Moves the per-company settings out of `companies` into their own table, so
# new settings do not keep widening the companies table.
class CreateCompanySettings < ActiveRecord::Migration[7.2]
  def up
    create_table :company_settings do |t|
      t.references :company, null: false, foreign_key: true, index: { unique: true }
      # Blocking a locker after wrong access codes
      t.integer :max_failed_attempts, null: false, default: 3
      t.integer :block_duration_minutes, null: false, default: 10
      t.timestamps
      t.check_constraint "max_failed_attempts > 0", name: "company_settings_max_failed_attempts_positive"
      t.check_constraint "block_duration_minutes > 0", name: "company_settings_block_duration_positive"
    end

    execute <<~SQL
      INSERT INTO company_settings (company_id, max_failed_attempts, block_duration_minutes, created_at, updated_at)
      SELECT id, max_failed_attempts, block_duration_minutes, NOW(), NOW() FROM companies
    SQL

    remove_column :companies, :max_failed_attempts
    remove_column :companies, :block_duration_minutes
  end

  def down
    add_column :companies, :max_failed_attempts, :integer, null: false, default: 3
    add_column :companies, :block_duration_minutes, :integer, null: false, default: 10
    add_check_constraint :companies, "max_failed_attempts > 0", name: "companies_max_failed_attempts_positive"
    add_check_constraint :companies, "block_duration_minutes > 0", name: "companies_block_duration_positive"

    execute <<~SQL
      UPDATE companies
      SET max_failed_attempts = company_settings.max_failed_attempts,
          block_duration_minutes = company_settings.block_duration_minutes
      FROM company_settings
      WHERE company_settings.company_id = companies.id
    SQL

    drop_table :company_settings
  end
end
