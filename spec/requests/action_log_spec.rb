require "rails_helper"

RSpec.describe "Action log" do
  let(:team) { create(:team) }
  let(:employee) { create(:user, team: team) }
  let(:support) { create(:user, :support) }
  let(:own_locker) { create(:locker, team: team) }
  let(:other_team_locker) { create(:locker, team: create(:team, company: team.company)) }
  let(:other_company_locker) { create(:locker) }

  # Rows on the page, as [locker, action, user].
  def log_rows
    Nokogiri::HTML(response.body).css("table tbody tr").map { |row| row.css("td").drop(1).map(&:text) }
  end

  # Choices offered by one of the filter's selects. Scoped to the filter form:
  # the mock sign-in dropdown in the header lists every user.
  def filter_options(name)
    Nokogiri::HTML(response.body).css("form[action='#{actions_path}'] select[name='#{name}'] option").map(&:text)
  end

  describe "GET /actions" do
    before do
      own_locker.perform!("open", by: employee)
      other_team_locker.perform!("open", by: support)
      other_company_locker.perform!("open", by: support)
      own_locker.perform!("close", by: support)
    end

    it "shows an employee the actions on their team's lockers only, newest first" do
      sign_in_as employee
      get actions_path

      expect(log_rows).to eq([
        [ own_locker.name, "Closed", support.name ],
        [ own_locker.name, "Opened", employee.name ]
      ])
    end

    it "shows a support engineer the actions on every locker" do
      sign_in_as support
      get actions_path

      expect(log_rows.map(&:first)).to eq(
        [ own_locker, other_company_locker, other_team_locker, own_locker ].map(&:name)
      )
    end

    it "narrows the log to one kind of action" do
      sign_in_as support
      get actions_path(kind: "close")

      expect(log_rows).to eq([ [ own_locker.name, "Closed", support.name ] ])
    end

    it "does not let the filter reach actions outside the user's lockers" do
      sign_in_as employee
      get actions_path(kind: "open")

      expect(log_rows).to eq([ [ own_locker.name, "Opened", employee.name ] ])
    end

    it "searches by locker name, ignoring case" do
      sign_in_as support
      get actions_path(q: other_team_locker.name.downcase)

      expect(log_rows).to eq([ [ other_team_locker.name, "Opened", support.name ] ])
    end

    it "searches by user name" do
      sign_in_as support
      get actions_path(q: employee.name)

      expect(log_rows).to eq([ [ own_locker.name, "Opened", employee.name ] ])
    end

    it "combines the search with the kind of action" do
      sign_in_as support
      get actions_path(q: own_locker.name, kind: "close")

      expect(log_rows).to eq([ [ own_locker.name, "Closed", support.name ] ])
    end

    it "does not let the search reach actions outside the user's lockers" do
      sign_in_as employee
      get actions_path(q: other_company_locker.name)

      expect(log_rows).to be_empty
    end

    it "treats % and _ in the search as plain text" do
      sign_in_as support
      get actions_path(q: "%")

      expect(log_rows).to be_empty
    end

    it "narrows the log to one locker" do
      sign_in_as support
      get actions_path(locker_id: other_team_locker.id)

      expect(log_rows).to eq([ [ other_team_locker.name, "Opened", support.name ] ])
    end

    it "narrows the log to one user" do
      sign_in_as support
      get actions_path(user_id: employee.id)

      expect(log_rows).to eq([ [ own_locker.name, "Opened", employee.name ] ])
    end

    it "ignores a locker filter pointing at a locker the user may not see" do
      sign_in_as employee
      get actions_path(locker_id: other_company_locker.id)

      expect(log_rows.map(&:first).uniq).to eq([ own_locker.name ])
      expect(response.body).not_to include(other_company_locker.name)
    end

    it "offers an employee only their lockers and the users who acted on them" do
      outsider = create(:user, name: "Outsider Only")
      other_company_locker.perform!("close", by: outsider)

      sign_in_as employee
      get actions_path

      expect(filter_options("locker_id")).to eq([ "All lockers", own_locker.name ])
      expect(filter_options("user_id")).to eq([ "All users", *[ employee.name, support.name ].sort ])
    end

    it "ignores an unknown kind" do
      sign_in_as employee
      get actions_path(kind: "explode")

      expect(log_rows.size).to eq(2)
    end
  end

  describe "pagination" do
    before do
      11.times { %w[open close].each { |kind| own_locker.perform!(kind, by: employee) } }
      sign_in_as employee
    end

    it "shows 20 actions per page with a link to the next page" do
      get actions_path

      expect(log_rows.size).to eq(20)
      expect(response.body).to include("Page 1 of 2", actions_path(page: 2))
    end

    it "shows the rest on the last page" do
      get actions_path(page: 2)

      expect(log_rows.size).to eq(2)
      expect(response.body).to include("Page 2 of 2")
    end

    it "keeps the search and the kind in the page links" do
      10.times { %w[open close].each { |kind| own_locker.perform!(kind, by: employee) } }
      get actions_path(q: own_locker.name, kind: "open")

      expect(response.body).to include(CGI.escapeHTML(actions_path(q: own_locker.name, kind: "open", page: 2)))
    end
  end
end
