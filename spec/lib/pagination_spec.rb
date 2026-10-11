require "rails_helper"

RSpec.describe Pagination do
  before { create_list(:company, 5) }

  let(:scope) { Company.order(:id) }

  it "returns one page of records" do
    pagination = described_class.new(scope, page: 2, per_page: 2)

    expect(pagination.records).to eq(scope[2, 2])
    expect(pagination).to have_attributes(page: 2, total_pages: 3, total_count: 5, previous_page: 1, next_page: 3)
  end

  it "has no previous page on the first page and no next page on the last" do
    expect(described_class.new(scope, page: 1, per_page: 2).previous_page).to be_nil
    expect(described_class.new(scope, page: 3, per_page: 2).next_page).to be_nil
  end

  it "falls back to the nearest page when the requested one does not exist" do
    expect(described_class.new(scope, page: 99, per_page: 2).page).to eq(3)
    expect(described_class.new(scope, page: "abc", per_page: 2).page).to eq(1)
    expect(described_class.new(scope, page: nil, per_page: 2).page).to eq(1)
  end

  it "has a single empty page when there are no records" do
    pagination = described_class.new(Company.none, page: 1)

    expect(pagination).to have_attributes(page: 1, total_pages: 1, records: be_empty)
  end
end
