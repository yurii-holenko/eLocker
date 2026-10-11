# Demo data covering every scenario: two companies, two teams each, employees
# in every team, an eLocker support engineer who sees everything, and enough
# lockers and history to see pagination on every screen.
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
  lockers: {
    "AMZ-BER-001" => "Berlin hub, bay 1", "AMZ-BER-002" => "Berlin hub, bay 1",
    "AMZ-BER-003" => "Berlin hub, bay 2", "AMZ-BER-004" => "Berlin hub, bay 2",
    "AMZ-BER-005" => "Berlin hub, bay 3", "AMZ-BER-006" => "Berlin hub, bay 3"
  }

seed_team "Amazon", "Warehouse night shift",
  users: [ "Chloe Nguyen" ],
  lockers: {
    "AMZ-BER-101" => "Berlin hub, bay 7", "AMZ-BER-102" => "Berlin hub, bay 7",
    "AMZ-BER-103" => "Berlin hub, bay 8", "AMZ-BER-104" => "Berlin hub, bay 8",
    "AMZ-BER-105" => "Berlin hub, bay 9", "AMZ-BER-106" => "Berlin hub, bay 9"
  }

seed_team "DPD", "North region crew",
  users: [ "Dmytro Koval" ],
  lockers: {
    "DPD-HAM-001" => "Hamburg central station", "DPD-HAM-002" => "Hamburg Altona mall",
    "DPD-HAM-003" => "Hamburg airport", "DPD-HAM-004" => "Hamburg harbour office",
    "DPD-HAM-005" => "Hamburg university", "DPD-HAM-006" => "Hamburg Wandsbek market"
  }

seed_team "DPD", "South region crew",
  users: [ "Elena Rossi" ],
  lockers: {
    "DPD-MUC-001" => "Munich airport, terminal 2", "DPD-MUC-002" => "Munich Ostbahnhof",
    "DPD-MUC-003" => "Munich Olympia mall", "DPD-MUC-004" => "Munich trade fair",
    "DPD-MUC-005" => "Munich Pasing station", "DPD-MUC-006" => "Munich university"
  }

support = User.find_or_create_by!(name: "Sam Support") { |user| user.role = "support" }

# A history for the action log: each team gets more than one page of actions
# (20 per page), so the support engineer sees several pages. It goes through
# Locker#perform!, the same code path as the UI. Skipped once a history exists.
if LockerAction.count < 30
  first_new_action = LockerAction.maximum(:id).to_i + 1

  Team.includes(:users, :lockers).order(:id).each do |team|
    employees = team.users.sort_by(&:id)
    closed_lockers = team.lockers.select(&:closed?).sort_by(&:name)

    closed_lockers.each_with_index do |locker, index|
      employee = employees[index % employees.size]

      locker.perform!("open", by: employee)
      locker.perform!("close", by: employee)
      # One wrong code is below every company's limit, so nothing gets blocked.
      locker.perform!("fail_attempt", by: employee)
      locker.perform!("open", by: index.even? ? employee : support)
      # Leave every third locker open, so the list shows both states.
      locker.perform!("close", by: employee) unless (index % 3).zero?
    end
  end

  # One locker that was blocked by wrong codes and then opened by support.
  blocked_once = Locker.find_by!(name: "DPD-HAM-006")
  crew_member = blocked_once.team.users.first
  blocked_once.company.settings.max_failed_attempts.times { blocked_once.perform!("fail_attempt", by: crew_member) }
  blocked_once.perform!("open", by: support)
  blocked_once.perform!("close", by: support)

  # Spread the history over the last few days instead of "all just now".
  new_actions = LockerAction.where(id: first_new_action..).order(:id).to_a
  new_actions.each_with_index do |action, index|
    action.update_columns(created_at: (new_actions.size - index).hours.ago)
  end
end
