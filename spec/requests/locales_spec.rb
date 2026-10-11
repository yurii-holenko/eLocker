require "rails_helper"

RSpec.describe "Locales" do
  let(:locker) { create(:locker) }

  before { sign_in_as create(:user, team: locker.team) }

  describe "PATCH /locale" do
    it "renders the page, including the React components, in the chosen language" do
      patch locale_path, params: { locale: "uk" }
      get lockers_path

      expect(response.body).to include('lang="uk"', "Локери", "Відчинити", "Користувач")
    end

    it "translates flash messages" do
      patch locale_path, params: { locale: "uk" }
      post locker_actions_path(locker), params: { kind: "open" }

      expect(flash[:notice]).to eq("#{locker.name} відчинено.")
    end

    it "falls back to English for an unsupported language" do
      patch locale_path, params: { locale: "xx" }
      get lockers_path

      expect(response.body).to include('lang="en"', "Lockers")
    end
  end
end
