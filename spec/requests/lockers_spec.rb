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

    it "splits a long list into pages of 20, without leaking other teams' lockers" do
      create_list(:locker, 21, team: team) # 22 with own_locker

      sign_in_as create(:user, team: team)
      get lockers_path
      expect(Nokogiri::HTML(response.body).css("table tbody tr").size).to eq(20)
      expect(response.body).to include("Page 1 of 2", lockers_path(page: 2))

      get lockers_path(page: 2)
      expect(Nokogiri::HTML(response.body).css("table tbody tr").size).to eq(2)
      expect(response.body).not_to include(other_team_locker.name, other_company_locker.name)
    end

    describe "filter" do
      let!(:open_locker) { create(:locker, :open, team: team, name: "OPEN-1", location: "North gate") }

      def listed
        Nokogiri::HTML(response.body).css("table tbody tr td:first-child").map(&:text)
      end

      def filter_options(name)
        Nokogiri::HTML(response.body).css("form[action='#{lockers_path}'] select[name='#{name}'] option").map(&:text)
      end

      it "searches by name or location, ignoring case" do
        sign_in_as create(:user, team: team)

        get lockers_path(q: "open-")
        expect(listed).to eq([ "OPEN-1" ])

        get lockers_path(q: "north GATE")
        expect(listed).to eq([ "OPEN-1" ])
      end

      it "narrows the list to one state" do
        sign_in_as create(:user, team: team)
        get lockers_path(state: "open")

        expect(listed).to eq([ "OPEN-1" ])
      end

      it "lets a support engineer narrow the list to one team" do
        sign_in_as create(:user, :support)
        get lockers_path(team_id: other_company_locker.team_id)

        expect(listed).to eq([ other_company_locker.name ])
      end

      it "does not let any filter reach lockers outside the user's team" do
        sign_in_as create(:user, team: team)

        get lockers_path(q: other_company_locker.name)
        expect(listed).to be_empty

        get lockers_path(team_id: other_company_locker.team_id)
        expect(listed).to contain_exactly(own_locker.name, "OPEN-1")
      end

      it "offers the team select only when there is more than one team to choose from" do
        sign_in_as create(:user, team: team)
        get lockers_path
        expect(filter_options("team_id")).to be_empty

        sign_in_as create(:user, :support)
        get lockers_path
        expect(filter_options("team_id").size).to eq(4) # "All teams" + three teams
      end

      it "keeps the filters in the page links" do
        create_list(:locker, 21, :open, team: team)
        sign_in_as create(:user, team: team)
        get lockers_path(state: "open")

        expect(response.body).to include(CGI.escapeHTML(lockers_path(state: "open", page: 2)))
      end
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
