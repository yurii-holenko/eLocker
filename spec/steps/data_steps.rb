# Steps that put records in the database. Tables use the column names below,
# so new scenarios rarely need new steps.
module DataSteps
  extend Turnip::DSL

  # | name | max wrong codes | block minutes |
  step "the following companies:" do |table|
    table.hashes.each do |row|
      settings = {
        max_failed_attempts: row["max wrong codes"].presence,
        block_duration_minutes: row["block minutes"].presence
      }.compact

      create(:company, name: row.fetch("name")).settings.update!(settings)
    end
  end

  # | name | company |
  step "the following teams:" do |table|
    table.hashes.each do |row|
      create(:team, name: row.fetch("name"), company: Company.find_by!(name: row.fetch("company")))
    end
  end

  # | name | team |
  step "the following employees:" do |table|
    table.hashes.each do |row|
      create(:user, name: row.fetch("name"), team: Team.find_by!(name: row.fetch("team")))
    end
  end

  step "a support engineer :name" do |name|
    create(:user, :support, name: name)
  end

  # | user | action | locker | times |    (times is optional)
  # Actions are performed in the order listed, through the same code path
  # the UI uses.
  step "the following actions happened:" do |table|
    table.hashes.each do |row|
      locker = Locker.find_by!(name: row.fetch("locker"))
      user = User.find_by!(name: row.fetch("user"))

      (row["times"].presence || 1).to_i.times { locker.perform!(row.fetch("action").tr(" ", "_"), by: user) }
    end
  end

  # | name | team | state | location |    (state and location are optional;
  # state is closed, open or blocked)
  step "the following lockers:" do |table|
    table.hashes.each do |row|
      traits = [ row["state"].presence&.to_sym ].compact - [ :closed ]
      attributes = { name: row.fetch("name"), team: Team.find_by!(name: row.fetch("team")) }
      attributes[:location] = row["location"] if row["location"].present?

      create(:locker, *traits, attributes)
    end
  end
end
