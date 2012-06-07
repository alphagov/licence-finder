source 'https://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'rails', '3.2.3'

gem "mongoid", "~> 2.4"
gem "bson_ext", "~> 1.5"
gem "tire"

gem 'router-client', '~> 3.0.1', :require => 'router'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 0.0.49'
end

gem 'rummageable', '~> 0.1.3'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '~> 1.1.39'
end

group :assets do
  #gem 'sass-rails',   '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem "ruby-debug19"
end

group :development, :test do
  gem 'rspec-rails', '~> 2.10.0'
  gem 'factory_girl_rails', '~> 3.2.0'
  gem 'database_cleaner'
  gem 'mocha', '~> 0.11.3', :require => false
  gem 'capybara', '~> 1.1.2'
  gem 'capybara-webkit', '~> 0.12.1'
  gem 'webmock', '~> 1.8.7', :require => false
end
