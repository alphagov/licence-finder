source 'https://rubygems.org'

gem 'rails', '5.2.0'
gem 'rails-controller-testing'
gem 'govuk_app_config', '~> 1.5.1'
gem 'plek', '2.1.1'

gem "mongoid", '~> 6.2.0'
gem 'elasticsearch'

gem 'mongoid_rails_migrations', '~> 1.1.0'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 52.6'
end

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '13.0.0'
end

gem 'sass-rails', '~> 5.0.7'
gem 'uglifier', '~> 4.1.12'

gem 'govuk_frontend_toolkit', '~> 7.5.0'
gem 'govuk_publishing_components', '~> 9.3.6'

gem 'govuk-lint', '~> 3.8.0'

group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.7.2'
  gem 'factory_girl_rails', '~> 4.9.0'
  gem 'database_cleaner', '~> 1.7.0'
  gem 'capybara', '~> 3.3.1'

  # TODO: 1.10.x is available, but it introduces a warning about using an old
  # version of phantomjs and suggests we upgrade to a version >= 2.1.1, we'll
  # stick to 1.9.x until we can get a newer phantomjs version.
  gem 'poltergeist', '~> 1.18.1'
  gem 'webmock', '~> 3.4.2'
  gem 'govuk-content-schema-test-helpers'
end
