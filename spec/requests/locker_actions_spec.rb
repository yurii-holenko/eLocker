require "rails_helper"

RSpec.describe "Locker actions" do
  let(:team) { create(:team) }
  let(:employee) { create(:user, team: team) }
  let(:support) { create(:user, :support) }
  let(:own_locker) { create(:locker, team: team) }

  describe "POST /lockers/:locker_id/actions" do
    it "lets an employee open a locker of their team" do
      sign_in_as employee

      expect { post locker_actions_path(own_locker), params: { kind: "open" } }
        .to change { own_locker.reload.state }.to("open")
        .and change(own_locker.actions, :count).by(1)

      expect(response).to redirect_to(lockers_path)
      expect(flash[:notice]).to eq("#{own_locker.name} is now open.")
      expect(own_locker.actions.last.user).to eq(employee)
    end

    it "hides lockers of another team in the same company from an employee" do
      locker = create(:locker, team: create(:team, company: team.company))
      sign_in_as employee

      expect { post locker_actions_path(locker), params: { kind: "open" } }
        .to not_change { locker.reload.state }
        .and not_change(LockerAction, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "hides lockers of another company from an employee" do
      locker = create(:locker, :open)
      sign_in_as employee

      expect { post locker_actions_path(locker), params: { kind: "close" } }
        .to not_change { locker.reload.state }
        .and not_change(LockerAction, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "lets a support engineer operate any locker" do
      locker = create(:locker, :open)
      sign_in_as support

      expect { post locker_actions_path(locker), params: { kind: "close" } }
        .to change { locker.reload.state }.to("closed")

      expect(locker.actions.last.user).to eq(support)
    end

    it "reports a repeated action instead of logging it twice" do
      locker = create(:locker, :open)
      sign_in_as support

      expect { post locker_actions_path(locker), params: { kind: "open" } }.not_to change(LockerAction, :count)

      expect(flash[:alert]).to eq("#{locker.name} is already open.")
    end

    it "warns about a wrong code and blocks the locker at the company's limit" do
      team.company.settings.update!(max_failed_attempts: 2, block_duration_minutes: 5)
      sign_in_as employee

      post locker_actions_path(own_locker), params: { kind: "fail_attempt" }
      expect(flash[:alert]).to eq("Wrong code for #{own_locker.name}. Attempts left: 1.")

      post locker_actions_path(own_locker), params: { kind: "fail_attempt" }
      expect(flash[:alert]).to eq("Too many wrong codes: #{own_locker.name} is blocked for 5 min.")
      expect(own_locker.reload).to be_blocked
    end

    it "refuses to open a blocked locker for an employee" do
      locker = create(:locker, :blocked, team: team)
      sign_in_as employee

      post locker_actions_path(locker), params: { kind: "open" }

      expect(locker.reload).to be_blocked
      expect(flash[:alert]).to include("Only eLocker support can open it")
    end

    it "lets a support engineer open a blocked locker" do
      locker = create(:locker, :blocked, team: team)
      sign_in_as support

      post locker_actions_path(locker), params: { kind: "open" }

      expect(locker.reload).to be_open
    end
  end
end
