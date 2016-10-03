RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean
    Mongoid::Tasks::Database.create_indexes
  end

  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
