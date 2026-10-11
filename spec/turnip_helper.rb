# Loaded by Turnip before any .feature file in spec/features.
require "rails_helper"
require "turnip/capybara"

Rails.root.glob("spec/steps/**/*.rb").sort.each { |file| require file }

# Scenarios run without a browser by default, which also proves every screen
# works as plain server-rendered HTML. Tag a scenario @javascript to run it in
# headless Chrome with React hydrated.
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.server = :puma, { Silent: true }
Capybara.enable_aria_label = true # the language dropdown is labelled with aria-label

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :feature

  # Turnip looks steps up as methods on the example; these modules define them.
  config.include DataSteps, type: :feature
  config.include NavigationSteps, type: :feature
  config.include PageSteps, type: :feature
  config.include TimeSteps, type: :feature
end
