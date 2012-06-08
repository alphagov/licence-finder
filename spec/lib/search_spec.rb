require "spec_helper"
require "search"

describe Search do

  before(:each) do
    @client = stub()
    @search = Search.new(@client)
  end

  it "should index all sectors with the configured client" do
    @client.expects(:pre_index)
    Sector.expects(:find_layer3_sectors).returns(:all_sectors)
    @client.expects(:index).with(:all_sectors)
    @client.expects(:post_index)

    @search.index_all
  end

  it "should pass delete_index on to the concrete client" do
    @client.expects(:delete_index)

    @search.delete_index
  end

  it "should pass search query on to concrete client" do
    s1 = FactoryGirl.create(:sector, public_id: 234)
    s2 = FactoryGirl.create(:sector, public_id: 123)

    @client.expects(:search).with(:query).returns([123, 234])

    @search.search(:query).should == [s2, s1]
  end
end