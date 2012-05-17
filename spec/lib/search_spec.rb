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

  it "should pass search query on to concrete client" do
    s1 = FactoryGirl.create(:sector, public_id: 234)
    s2 = FactoryGirl.create(:sector, public_id: 123)
    client = stub()

    client.expects(:search).with(:query).returns([123, 234])

    search = Search.new(client)
    search.search(:query).should == [s2, s1]
  end
end