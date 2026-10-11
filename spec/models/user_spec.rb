require "rails_helper"

RSpec.describe User do
  it { is_expected.to have_one(:company).through(:team) }
  it { is_expected.to validate_presence_of(:name) }

  it do
    is_expected.to define_enum_for(:role)
      .with_values(employee: "employee", support: "support")
      .backed_by_column_of_type(:string)
  end

  it "rejects an unknown role instead of raising" do
    expect(build(:user, role: "admin")).not_to be_valid
  end

  context "when an employee" do
    subject { build(:user) }

    it { is_expected.to be_employee }
    it { is_expected.to validate_presence_of(:team) }
  end

  context "when a support engineer" do
    subject { build(:user, :support) }

    it { is_expected.to be_support }
    it { is_expected.to belong_to(:team).optional }
    it { is_expected.to validate_absence_of(:team) }
  end
end
