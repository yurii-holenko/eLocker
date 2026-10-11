require "rails_helper"

RSpec.describe Locker do
  subject { build(:locker) }

  it { is_expected.to belong_to(:team) }
  it { is_expected.to have_one(:company).through(:team) }
  it { is_expected.to have_many(:actions).class_name("LockerAction").dependent(:restrict_with_exception) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:location) }

  describe "state machine" do
    let(:employee) { build(:user) }
    let(:support) { build(:user, :support) }

    # Events take the acting user, which the guards check.
    def allowed_events(locker, user)
      %i[open close fail_attempt block unblock].select { |event| locker.aasm.may_fire_event?(event, user) }
    end

    it { is_expected.to have_state(:closed) }

    it "lets an employee open a closed locker or enter a wrong code; the system may block it" do
      expect(allowed_events(build(:locker), employee)).to eq(%i[open fail_attempt block])
    end

    it "does not take wrong codes from support, who open lockers without one" do
      expect(allowed_events(build(:locker), support)).to eq(%i[open block])
    end

    it "lets an open locker only be closed" do
      expect(allowed_events(build(:locker, :open), employee)).to eq(%i[close])
    end

    it "lets nobody but support touch a blocked locker" do
      locker = build(:locker, :blocked)

      expect(allowed_events(locker, employee)).to be_empty
      expect(allowed_events(locker, support)).to eq(%i[open])
    end

    it "lets anyone open, and the system unblock, a locker whose block has run out" do
      expect(allowed_events(build(:locker, :blocked, blocked_until: 1.second.ago), employee)).to eq(%i[open unblock])
    end

    it "moves to the expected state on each event" do
      locker = create(:locker)

      expect { locker.fail_attempt!(employee) }.not_to change(locker, :state)
      expect { locker.open!(employee) }.to change(locker, :state).to("open")
      expect { locker.close!(employee) }.to change(locker, :state).to("closed")
      expect { locker.block!(employee) }.to change(locker, :state).to("blocked")
      expect { locker.open!(support) }.to change(locker, :state).to("open")
    end

    it "raises on a transition that is not listed" do
      expect { build(:locker).close!(employee) }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe ".search" do
    let!(:berlin) { create(:locker, name: "AMZ-BER-001", location: "Berlin hub, bay 1") }
    let!(:hamburg) { create(:locker, name: "DPD-HAM-001", location: "Hamburg central station") }

    it "matches part of the name, ignoring case" do
      expect(described_class.search("amz-ber")).to contain_exactly(berlin)
    end

    it "matches part of the location" do
      expect(described_class.search("central")).to contain_exactly(hamburg)
    end

    it "treats LIKE wildcards as plain text" do
      expect(described_class.search("%")).to be_empty
    end
  end

  describe ".accessible_to" do
    let(:team) { create(:team) }
    let!(:own_locker) { create(:locker, team: team) }
    let!(:other_team_locker) { create(:locker, team: create(:team, company: team.company)) }
    let!(:other_company_locker) { create(:locker) }

    it "returns only the lockers of an employee's team" do
      expect(described_class.accessible_to(create(:user, team: team))).to contain_exactly(own_locker)
    end

    it "returns every locker for a support engineer" do
      expect(described_class.accessible_to(create(:user, :support)))
        .to contain_exactly(own_locker, other_team_locker, other_company_locker)
    end
  end

  describe "#perform!" do
    let(:company) { create(:company_setting, max_failed_attempts: 2, block_duration_minutes: 5).company }
    let(:team) { create(:team, company: company) }
    let(:locker) { create(:locker, team: team) }
    let(:user) { create(:user, team: team) }
    let(:support) { create(:user, :support) }

    it "changes the state and records who did it" do
      expect { locker.perform!("open", by: user) }
        .to change { locker.reload.state }.from("closed").to("open")
        .and change(locker.actions, :count).by(1)

      expect(locker.actions.last).to have_attributes(kind: "open", user: user)
    end

    it "rejects an action that would not change the state" do
      expect { locker.perform!("close", by: user) }
        .to raise_error(Locker::InvalidAction, "#{locker.name} is already closed.")
        .and not_change(LockerAction, :count)
    end

    it "rejects events that only the system may fire" do
      expect { locker.perform!("block", by: user) }.to raise_error(Locker::InvalidAction, "Unknown action.")
    end

    it "rejects an unknown action" do
      expect { locker.perform!("explode", by: user) }.to raise_error(Locker::InvalidAction, "Unknown action.")
    end

    describe "wrong access codes" do
      it "records the attempt and keeps the locker closed below the company's limit" do
        locker.perform!("fail_attempt", by: user)

        expect(locker.reload).to be_closed
        expect(locker.actions.pluck(:kind)).to eq(%w[fail_attempt])
        expect(locker.failed_attempts_left_for(user)).to eq(1)
      end

      it "blocks the locker for the company's duration once the limit is reached" do
        freeze_time do
          2.times { locker.perform!("fail_attempt", by: user) }

          expect(locker.reload).to be_blocked
          expect(locker.blocked_until).to eq(5.minutes.from_now)
          expect(locker.actions.order(:id).pluck(:kind)).to eq(%w[fail_attempt fail_attempt block])
          expect(locker.actions.last).to have_attributes(kind: "block", user: nil) # done by the system
          expect(UnblockLockerJob).to have_been_enqueued.with(locker).at(5.minutes.from_now)
        end
      end

      it "counts attempts per user" do
        locker.perform!("fail_attempt", by: user)
        locker.perform!("fail_attempt", by: create(:user, team: team))

        expect(locker.reload).to be_closed
      end

      it "starts counting again after the user opens the locker" do
        locker.perform!("fail_attempt", by: user)
        locker.perform!("open", by: user)
        locker.perform!("close", by: user)
        locker.perform!("fail_attempt", by: user)

        expect(locker.reload).to be_closed
      end

      it "is not available to support engineers, who open lockers without a code" do
        expect { locker.perform!("fail_attempt", by: support) }
          .to raise_error(Locker::InvalidAction, "Support engineers open lockers without a code.")
      end
    end

    context "when the locker is blocked" do
      before { 2.times { locker.perform!("fail_attempt", by: user) } }

      it "cannot be opened by an employee" do
        expect { locker.perform!("open", by: user) }.to raise_error(Locker::InvalidAction, /is blocked/)
        expect(locker.reload).to be_blocked
      end

      it "can be opened by a support engineer" do
        locker.perform!("open", by: support)

        expect(locker.reload).to be_open
        expect(locker.blocked_until).to be_nil
      end

      it "can be opened by an employee once the block has run out" do
        travel 6.minutes do
          locker.perform!("open", by: user)

          expect(locker.reload).to be_open
        end
      end

      it "starts counting wrong codes again after the block" do
        travel(6.minutes) { locker.unblock_if_expired! }
        locker.perform!("fail_attempt", by: user)

        expect(locker.reload).to be_closed
      end
    end
  end

  describe "#unblock_if_expired!" do
    let!(:locker) { create(:locker, :blocked) }

    it "closes the locker and logs a system action once the block has run out" do
      travel 11.minutes do
        locker.unblock_if_expired!

        expect(locker.reload).to be_closed
        expect(locker.blocked_until).to be_nil
        expect(locker.actions.last).to have_attributes(kind: "unblock", user: nil)
      end
    end

    it "does nothing while the block is still running" do
      expect { locker.unblock_if_expired! }.not_to change(LockerAction, :count)
      expect(locker.reload).to be_blocked
    end

    it "does nothing when support has already opened the locker" do
      locker.perform!("open", by: create(:user, :support))

      expect { travel(11.minutes) { locker.unblock_if_expired! } }.not_to change { locker.reload.state }
    end
  end

  describe "#available_events_for" do
    let(:employee) { build(:user) }
    let(:support) { build(:user, :support) }

    it "offers a closed locker's employee to open it or enter a wrong code" do
      expect(build(:locker).available_events_for(employee)).to eq(%w[open fail_attempt])
    end

    it "offers nothing to an employee while the locker is blocked" do
      expect(build(:locker, :blocked).available_events_for(employee)).to be_empty
    end

    it "offers support to open a blocked locker" do
      expect(build(:locker, :blocked).available_events_for(support)).to eq(%w[open])
    end
  end
end
