# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_10_11_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "company_settings", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.integer "max_failed_attempts", default: 3, null: false
    t.integer "block_duration_minutes", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_settings_on_company_id", unique: true
    t.check_constraint "block_duration_minutes > 0", name: "company_settings_block_duration_positive"
    t.check_constraint "max_failed_attempts > 0", name: "company_settings_max_failed_attempts_positive"
  end

  create_table "locker_actions", force: :cascade do |t|
    t.bigint "locker_id", null: false
    t.bigint "user_id"
    t.string "kind", null: false
    t.datetime "created_at", null: false
    t.index ["locker_id", "created_at"], name: "index_locker_actions_on_locker_id_and_created_at"
    t.index ["locker_id"], name: "index_locker_actions_on_locker_id"
    t.index ["user_id"], name: "index_locker_actions_on_user_id"
    t.check_constraint "kind::text = ANY (ARRAY['open'::character varying, 'close'::character varying, 'fail_attempt'::character varying, 'block'::character varying, 'unblock'::character varying]::text[])", name: "locker_actions_kind_valid"
  end

  create_table "lockers", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.string "name", null: false
    t.string "location", null: false
    t.string "state", default: "closed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "blocked_until"
    t.index ["name"], name: "index_lockers_on_name", unique: true
    t.index ["team_id"], name: "index_lockers_on_team_id"
    t.check_constraint "(state::text = 'blocked'::text) = (blocked_until IS NOT NULL)", name: "lockers_blocked_until_matches_state"
    t.check_constraint "state::text = ANY (ARRAY['open'::character varying, 'closed'::character varying, 'blocked'::character varying]::text[])", name: "lockers_state_valid"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_teams_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_teams_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "role", default: "employee", null: false
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_users_on_team_id"
    t.check_constraint "(role::text = 'employee'::text) = (team_id IS NOT NULL)", name: "users_team_matches_role"
  end

  add_foreign_key "company_settings", "companies"
  add_foreign_key "locker_actions", "lockers"
  add_foreign_key "locker_actions", "users"
  add_foreign_key "lockers", "teams"
  add_foreign_key "teams", "companies"
  add_foreign_key "users", "teams"
end
