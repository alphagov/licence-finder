source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'unicorn', '4.3.1'
gem 'plek', '1.11.0'

gem "mongoid", '~> 4.0'
gem "tire"

gem 'mongoid_rails_migrations', '1.0.1'

gem "airbrake", "4.3.1"

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 24.4.0'
end

gem 'rummageable', '~> 0.1.3'
gem 'logstasher', '0.4.8'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '9.0.0'
end

gem 'sass-rails', '~> 5.0.4'
gem 'uglifier', '2.7.2'

group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.3.3'
  gem 'factory_girl_rails', '~> 4.5.0'

  # NOTE: 1.5.0 has a bug with mongoid and truncation: https://github.com/DatabaseCleaner/database_cleaner/issues/299
  gem 'database_cleaner', '~> 1.4.0'
  gem 'capybara', '2.5.0'
  gem 'poltergeist', '1.7.0'
  gem 'webmock', '1.8.11', :require => false
  gem 'govuk-content-schema-test-helpers'
end

gem 'govuk_frontend_toolkit', '0.41.1'
