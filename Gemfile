source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.22'
gem 'unicorn', '4.3.1'
gem 'plek', '1.1.0'

gem "mongoid", "2.4.9"
gem "bson_ext", "1.6.2"
gem "tire"

gem 'mongoid_rails_migrations', '1.0.1'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '8.2.1'
end

gem 'rummageable', '~> 0.1.3'
gem 'logstasher', '0.4.8'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '8.2.1'
end

gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'exception_notification'

group :assets do
  gem 'sass', '3.2.0'
  gem 'sass-rails', '3.2.5'
  gem 'uglifier', '1.2.4'
end

if ENV['RUBY_DEBUG']
  gem "ruby-debug19"
end

group :development, :test do
  gem 'rspec-rails', '2.11.0'
  gem 'factory_girl_rails', '3.2.0'
  gem 'database_cleaner'
  gem 'capybara', '2.4.4'
  gem 'poltergeist', "1.5.1"
  gem 'webmock', '1.8.7', :require => false
end

gem 'govuk_frontend_toolkit', '0.32.2'
