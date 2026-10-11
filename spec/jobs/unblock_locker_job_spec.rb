require "rails_helper"

RSpec.describe UnblockLockerJob do
  it "closes a locker whose block has run out" do
    locker = create(:locker, :blocked, blocked_until: 1.second.ago)

    described_class.perform_now(locker)

    expect(locker.reload).to be_closed
  end

  it "leaves a locker that is still blocked" do
    locker = create(:locker, :blocked)

    described_class.perform_now(locker)

    expect(locker.reload).to be_blocked
  end
end
