require 'gds_api/test_helpers/content_api'
require 'gds_api/test_helpers/publisher'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::ContentApi, :type => :controller
  config.before(:each, :type => :controller) do
    stub_content_api_default_artefact
  end

  config.include GdsApi::TestHelpers::ContentApi, :type => :request
  config.include GdsApi::TestHelpers::Publisher, :type => :request
  config.before(:each, :type => :request) do
    stub_content_api_default_artefact
    setup_content_api_licences_stubs
  end
end
