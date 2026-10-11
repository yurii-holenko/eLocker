require "rails_helper"

RSpec.describe "Sessions" do
  describe "PATCH /session" do
    it "switches the current user" do
      team = create(:team)
      locker = create(:locker, team: team)

      sign_in_as create(:user, team: team)

      expect(response).to redirect_to(root_path)
      get lockers_path
      expect(response.body).to include(locker.name)
    end

    it "responds with 404 for an unknown user" do
      patch session_path, params: { user_id: 0 }

      expect(response).to have_http_status(:not_found)
    end
  end
end
