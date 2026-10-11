require "rails_helper"

RSpec.describe Company do
  subject { build(:company) }

  it { is_expected.to have_many(:teams).dependent(:restrict_with_exception) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to have_one(:settings).class_name("CompanySetting").dependent(:destroy) }

  describe "#settings" do
    it "falls back to the defaults when the company has not saved any" do
      expect(create(:company).settings).to have_attributes(max_failed_attempts: 3, block_duration_minutes: 10)
    end

    it "returns the company's saved settings" do
      settings = create(:company_setting, max_failed_attempts: 5)

      expect(settings.company.reload.settings).to eq(settings)
    end
  end
end
