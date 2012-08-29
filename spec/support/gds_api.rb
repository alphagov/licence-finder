require 'gds_api/test_helpers/panopticon'
require 'gds_api/test_helpers/publisher'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::Panopticon, :type => :controller
  config.before(:each, :type => :controller) do
    stub_panopticon_default_artefact
  end

  config.include GdsApi::TestHelpers::Panopticon, :type => :request
  config.include GdsApi::TestHelpers::Publisher, :type => :request
  config.before(:each, :type => :request) do
    stub_panopticon_default_artefact
    setup_publisher_licences_stubs
  end
end
