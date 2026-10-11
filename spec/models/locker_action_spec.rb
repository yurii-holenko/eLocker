require "rails_helper"

RSpec.describe LockerAction do
  it { is_expected.to belong_to(:locker) }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to validate_inclusion_of(:kind).in_array(%w[open close fail_attempt block unblock]) }

  describe ".search" do
    let!(:action) { create(:locker_action, locker: create(:locker, name: "AMZ-BER-001"), user: nil) }
    let!(:by_alice) { create(:locker_action, user: create(:user, name: "Alice Carter")) }

    it "matches part of the locker's name, ignoring case" do
      expect(described_class.search("amz-ber")).to contain_exactly(action)
    end

    it "matches part of the user's name" do
      expect(described_class.search("carter")).to contain_exactly(by_alice)
    end

    it "finds system actions, which have no user, by locker name" do
      expect(described_class.search("AMZ")).to include(action)
    end

    it "treats LIKE wildcards as plain text" do
      expect(described_class.search("%")).to be_empty
    end
  end

  describe ".accessible_to" do
    let(:team) { create(:team) }
    let!(:own_action) { create(:locker_action, locker: create(:locker, team: team)) }
    let!(:other_team_action) { create(:locker_action, locker: create(:locker, team: create(:team, company: team.company))) }
    let!(:other_company_action) { create(:locker_action) }

    it "returns only actions on the lockers of an employee's team" do
      expect(described_class.accessible_to(create(:user, team: team))).to contain_exactly(own_action)
    end

    it "returns every action for a support engineer" do
      expect(described_class.accessible_to(create(:user, :support)))
        .to contain_exactly(own_action, other_team_action, other_company_action)
    end
  end
end
