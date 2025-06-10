source "https://rubygems.org"

ruby "3.2.8"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "bootsnap", require: false

# Pagination
gem 'kaminari'

# Development and test gems
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem "web-console"
  gem "listen", "~> 3.3"
end

group :test do
  gem 'database_cleaner-active_record'
end
