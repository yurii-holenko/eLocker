source "https://rubygems.org"

gem "rails", "~> 7.2.4"
gem "propshaft"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# Background jobs
gem "sidekiq", "~> 8.0"

group :development, :test do
  gem "dotenv-rails"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
end

group :test do
  gem "shoulda-matchers", "~> 7.0"
  # Feature tests: Gherkin scenarios run by RSpec, driving the app with Capybara
  gem "capybara"
  gem "turnip"
  gem "selenium-webdriver"
end

group :development do
  gem "web-console"
  # Warns about N+1 queries and unused eager loading
  gem "bullet"
end

gem "shakapacker", "~> 10.3"

gem "react_on_rails", "~> 17.1"

gem "aasm", "~> 6.0"
