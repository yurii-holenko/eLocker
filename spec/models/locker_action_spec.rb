require "rails_helper"

RSpec.describe LockerAction do
  it { is_expected.to belong_to(:locker) }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to validate_inclusion_of(:kind).in_array(%w[open close fail_attempt block unblock]) }
end
