source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'unicorn', '4.3.1'
gem 'plek', '1.12.0'

gem "mongoid", '~> 4.0'
gem "tire"

gem 'mongoid_rails_migrations', '1.0.1'

gem "airbrake", "~> 4.3.1"

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 25.1'
end

gem 'logstasher', '~> 0.6.0'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '9.5.0'
end

gem 'sass-rails', '~> 5.0.4'
gem 'uglifier', '2.7.2'

group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'database_cleaner', '~> 1.5.1'
  gem 'capybara', '~> 2.8.0'

  # TODO: 1.10.x is available, but it introduces a warning about using an old
  # version of phantomjs and suggests we upgrade to a version >= 2.1.1, we'll
  # stick to 1.9.x until we can get a newer phantomjs version.
  gem 'poltergeist', '~> 1.9.0'
  gem 'webmock', '~> 2.1.0'
  gem 'govuk-content-schema-test-helpers'
end

gem 'govuk_frontend_toolkit', '0.41.1'
