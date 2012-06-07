require 'gds_api/test_helpers/publisher'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::Publisher, :type => :request
  config.before(:each, :type => :request) do
    setup_publisher_licences_stubs
  end
end
