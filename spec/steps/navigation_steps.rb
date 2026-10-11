# Steps for moving around the app as a user would.
module NavigationSteps
  extend Turnip::DSL

  PAGES = { "Lockers" => "/lockers" }.freeze

  # Authentication is mocked: signing in is picking a user in the header.
  step "I am signed in as :name" do |name|
    visit root_path
    choose_in_header name, from: "Signed in as"
    expect(page).to have_select("Signed in as", selected: name)
  end

  step "I select :language as the language" do |language|
    choose_in_header language, from: "Language"
  end

  step "I open the :title page" do |title|
    visit PAGES.fetch(title)
  end

  # The header dropdowns submit on change in a browser; without JavaScript
  # their form shows a button instead.
  def choose_in_header(value, from:)
    dropdown = find_field(from)
    dropdown.select(value)

    within(dropdown.find(:xpath, "ancestor::form")) do
      click_button if has_button?(wait: 0)
    end
  end
end
