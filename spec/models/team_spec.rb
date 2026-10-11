require "rails_helper"

RSpec.describe Team do
  subject { build(:team) }

  it { is_expected.to belong_to(:company) }
  it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  it { is_expected.to have_many(:lockers).dependent(:restrict_with_exception) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
end
