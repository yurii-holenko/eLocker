source "https://rubygems.org"

gem "rails", "~> 7.2.4"
gem "propshaft"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# Background jobs
gem "sidekiq", "~> 8.0"

group :development, :test do
  gem "dotenv-rails"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
