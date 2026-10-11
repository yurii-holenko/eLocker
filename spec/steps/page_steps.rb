# Steps that act on, or check, whatever page is on screen. They know nothing
# about lockers: a "row" is any table row containing the given text.
module PageSteps
  extend Turnip::DSL

  step "I press :button" do |button|
    click_button button
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
