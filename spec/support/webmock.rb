require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)

    stub_request(:get, Plek.new.find("content-store") + "/content/licence-finder").to_return(body: {}.to_json)
    stub_request(:get, %r{#{Plek.new.find("static")}/templates/locales(.*)}).to_return(body: {}.to_json)
  end
end
