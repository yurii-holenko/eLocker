require "rails_helper"

RSpec.describe CompanySetting do
  subject { build(:company_setting) }

  it { is_expected.to belong_to(:company) }
  it { is_expected.to validate_uniqueness_of(:company_id) }
  it { is_expected.to validate_numericality_of(:max_failed_attempts).only_integer.is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:block_duration_minutes).only_integer.is_greater_than(0) }

  it "blocks a locker after 3 wrong codes for 10 minutes by default" do
    expect(described_class.new).to have_attributes(max_failed_attempts: 3, block_duration_minutes: 10)
  end
end
