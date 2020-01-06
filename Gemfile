source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '5.2.4'
gem 'rails-controller-testing'
gem 'govuk_app_config', '~> 2.0.1'
gem 'plek', '3.0.0'

gem "mongoid", '~> 6.2.0'
gem 'elasticsearch'

gem 'mongoid_rails_migrations', '~> 1.1.0'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 63.1'
end

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '13.2.0'
end

gem 'sass-rails', '~> 5.0.7'
gem 'uglifier', '~> 4.2.0'

gem 'govuk_frontend_toolkit', '~> 9.0.0'
gem 'govuk_publishing_components', '~> 21.17.0'

gem 'rubocop-govuk'

group :development, :test do
  gem 'database_cleaner', '~> 1.7.0'
  gem 'factory_bot_rails'
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk_test'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.9.0'
  gem 'webmock', '~> 3.7.6'
end
