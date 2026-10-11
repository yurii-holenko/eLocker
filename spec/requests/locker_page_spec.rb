require "rails_helper"

RSpec.describe "Locker page" do
  let(:team) { create(:team) }
  let(:employee) { create(:user, team: team) }
  let(:support) { create(:user, :support) }
  let(:locker) { create(:locker, team: team, location: "Berlin hub, bay 1") }

  # History rows on the page, as [action, user].
  def history_rows
    Nokogiri::HTML(response.body).css("table tbody tr").map { |row| row.css("td").drop(1).map(&:text) }
  end

  describe "GET /lockers/:id" do
    it "shows an employee the details of a locker of their team" do
      sign_in_as employee
      get locker_path(locker)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(locker.name, "Berlin hub, bay 1", team.name, team.company.name, "Closed")
    end

    it "responds with 404 for a locker of another team in the same company" do
      sign_in_as employee
      get locker_path(create(:locker, team: create(:team, company: team.company)))

      expect(response).to have_http_status(:not_found)
    end

    it "responds with 404 for a locker of another company" do
      sign_in_as employee
      get locker_path(create(:locker))

      expect(response).to have_http_status(:not_found)
    end

    it "shows a support engineer any locker" do
      sign_in_as support
      get locker_path(locker)

      expect(response).to have_http_status(:ok)
    end

    it "lists only this locker's actions, newest first" do
      other_locker = create(:locker, team: team)
      locker.perform!("open", by: employee)
      other_locker.perform!("fail_attempt", by: employee)
      locker.perform!("close", by: support)

      sign_in_as employee
      get locker_path(locker)

      expect(history_rows).to eq([ [ "Closed", support.name ], [ "Opened", employee.name ] ])
    end

    it "shows the system as the author of a timed unblock" do
      blocked = create(:locker, :blocked, team: team, blocked_until: 1.second.ago)
      blocked.unblock_if_expired!

      sign_in_as employee
      get locker_path(blocked)

      expect(history_rows).to eq([ %w[Unblocked System] ])
    end

    it "tells an employee how many wrong codes they have left, but not support" do
      team.company.settings.update!(max_failed_attempts: 4)
      locker.perform!("fail_attempt", by: employee)

      sign_in_as employee
      get locker_path(locker)
      expect(response.body).to include("3 of 4")

      sign_in_as support
      get locker_path(locker)
      expect(response.body).not_to include("3 of 4", "4 of 4")
    end

    it "splits the history into pages of 20" do
      11.times { %w[open close].each { |kind| locker.perform!(kind, by: employee) } }
      sign_in_as employee

      get locker_path(locker)
      expect(history_rows.size).to eq(20)
      expect(response.body).to include("Page 1 of 2", locker_path(locker, page: 2))

      get locker_path(locker, page: 2)
      expect(history_rows.size).to eq(2)
    end
  end

  describe "POST /lockers/:locker_id/actions from the locker page" do
    it "returns to the locker page" do
      sign_in_as employee
      post locker_actions_path(locker), params: { kind: "open" }, headers: { "Referer" => locker_url(locker) }

      expect(response).to redirect_to(locker_url(locker))
    end
  end
end
