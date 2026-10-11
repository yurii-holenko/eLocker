# Demo data covering every scenario: two companies, two teams each, employees
# in every team, and an eLocker support engineer who sees everything.
# Safe to run more than once.

def seed_team(company_name, team_name, users:, lockers:)
  company = Company.find_by!(name: company_name)
  team = company.teams.find_or_create_by!(name: team_name)

  users.each { |name| team.users.find_or_create_by!(name: name) { |user| user.role = "employee" } }
  lockers.each do |name, location|
    Locker.find_or_create_by!(name: name) { |locker| locker.assign_attributes(team: team, location: location) }
  end
end

# Amazon keeps the default blocking rules (3 wrong codes, 10 minutes); DPD is
# stricter and uses a short block so the timed unblock is easy to try out.
Company.find_or_create_by!(name: "Amazon")
Company.find_or_create_by!(name: "DPD").settings.update!(max_failed_attempts: 2, block_duration_minutes: 1)

seed_team "Amazon", "Warehouse day shift",
  users: [ "Alice Carter", "Ben Ortiz" ],
  lockers: { "AMZ-BER-001" => "Berlin hub, bay 1", "AMZ-BER-002" => "Berlin hub, bay 1", "AMZ-BER-003" => "Berlin hub, bay 2" }

seed_team "Amazon", "Warehouse night shift",
  users: [ "Chloe Nguyen" ],
  lockers: { "AMZ-BER-101" => "Berlin hub, bay 7", "AMZ-BER-102" => "Berlin hub, bay 7" }

seed_team "DPD", "North region crew",
  users: [ "Dmytro Koval" ],
  lockers: { "DPD-HAM-001" => "Hamburg central station", "DPD-HAM-002" => "Hamburg Altona mall" }

seed_team "DPD", "South region crew",
  users: [ "Elena Rossi" ],
  lockers: { "DPD-MUC-001" => "Munich airport, terminal 2", "DPD-MUC-002" => "Munich Ostbahnhof" }

User.find_or_create_by!(name: "Sam Support") { |user| user.role = "support" }
