require "rails_helper"

RSpec.describe "Lockers" do
  let(:team) { create(:team) }
  let!(:own_locker) { create(:locker, team: team) }
  let!(:other_team_locker) { create(:locker, team: create(:team, company: team.company)) }
  let!(:other_company_locker) { create(:locker) }

  # Action buttons rendered on the page: kind => how many.
  def offered_actions
    response.body.scan(/name="kind" value="(\w+)"/).flatten.tally
  end

  describe "GET /lockers" do
    it "shows an employee only the lockers of their team" do
      sign_in_as create(:user, team: team)
      get lockers_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(own_locker.name)
      expect(response.body).not_to include(other_team_locker.name)
      expect(response.body).not_to include(other_company_locker.name)
    end

    it "shows a support engineer the lockers of every company" do
      sign_in_as create(:user, :support)
      get lockers_path

      expect(response.body).to include(own_locker.name, other_team_locker.name, other_company_locker.name)
    end

    it "offers only the actions the state machine allows the viewer" do
      create(:locker, :blocked, team: team, name: "BLOCKED-1")

      sign_in_as create(:user, team: team)
      get lockers_path
      expect(response.body).to include("Blocked", "10 min left")
      expect(offered_actions).to eq("open" => 1, "fail_attempt" => 1) # own_locker only

      sign_in_as create(:user, :support)
      get lockers_path
      expect(offered_actions).to eq("open" => 4)
    end
  end
end
