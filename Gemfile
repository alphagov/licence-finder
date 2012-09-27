source 'https://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'rails', '~> 3.2.8'
gem 'unicorn', '4.3.1'

gem "mongoid", "~> 2.4"
gem "bson_ext", "~> 1.5"
gem "tire"

gem 'router-client', '~> 3.0.1', :require => 'router'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '2.1.0'
end

gem 'rummageable', '~> 0.1.3'
gem 'lograge'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '3.3.2'
end

gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'exception_notification'

group :assets do
  gem 'sass', '3.2.0'
  gem 'sass-rails',   '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby
  gem 'uglifier', '>= 1.0.3'
end

if ENV['RUBY_DEBUG']
  gem "ruby-debug19"
end

group :development, :test do
  gem 'rspec-rails', '~> 2.11.0'
  gem 'factory_girl_rails', '~> 3.2.0'
  gem 'database_cleaner'
  gem 'capybara', '~> 1.1.2'
  gem 'poltergeist', "~> 0.7.0"
  gem 'webmock', '~> 1.8.7', :require => false
end

gem 'govuk_frontend_toolkit', '0.2.1'
