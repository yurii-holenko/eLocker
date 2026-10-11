# Steps that act on, or check, whatever page is on screen. They know nothing
# about lockers: a "row" is any table row containing the given text.
module PageSteps
  extend Turnip::DSL

  step "I press :button" do |button|
    click_button button
  end

  step "I fill in :field with :value" do |field, value|
    fill_in field, with: value
  end

  step "I select :option from :field" do |option, field|
    select option, from: field
  end

  step "the :field select should offer :options" do |field, options|
    expect(find_field(field).all("option").map(&:text)).to eq(options.split(/,\s*|\s+and\s+/))
  end

  step "I follow :link" do |link|
    click_link link
  end

  step "I follow :link in the :row row" do |link, row|
    within(:table_row_with, row) { click_link link }
  end

  step "I reload the page" do
    visit current_path
  end

  step "I press :button in the :row row" do |button, row|
    within(:table_row_with, row) { click_button button }
  end

  step "I should see :text" do |text|
    expect(page).to have_content(text)
  end

  step "I should not see :text" do |text|
    expect(page).to have_no_content(text)
  end

  step "the :row row should show :text" do |row, text|
    within(:table_row_with, row) { expect(page).to have_content(text) }
  end

  step "the :row row should have the buttons :buttons" do |row, buttons|
    within(:table_row_with, row) do
      expect(all("button").map(&:text)).to match_array(buttons.split(/,\s*|\s+and\s+/))
    end
  end

  step "the :row row should have no buttons" do |row|
    within(:table_row_with, row) { expect(page).to have_no_button }
  end

  step "the table should have :count row(s)" do |count|
    expect(page).to have_css("table tbody tr", count: count.to_i)
  end

  # Compares the whole table: the header row names the columns to check.
  step "I should see the table:" do |expected|
    headers = all("table thead th").map(&:text)
    columns = expected.headers.map { |header| headers.index(header) || raise("No column #{header.inspect}") }
    rows = all("table tbody tr").map { |tr| tr.all("td").map(&:text).values_at(*columns) }

    expect(rows).to eq(expected.rows)
  end
end

Capybara.add_selector(:table_row_with) do
  xpath { |text| XPath.descendant(:tr)[XPath.string.n.contains(text)] }
end
