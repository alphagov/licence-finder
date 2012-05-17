require "spec_helper"
require "search"

describe Search do

  it "should index all sectors with the configured client" do
    client = stub()
    client.expects(:pre_index)
    Sector.expects(:all).returns(:all_sectors)
    client.expects(:index).with(:all_sectors)
    client.expects(:post_index)

    search = Search.new(client)
    search.index_all
  end
end