require "spec_helper"
require "search"

describe Search do

  before(:each) do
    @client = stub()
    @search = Search.new(@client)
  end

  it "should index all sectors with the configured client" do
    @client.should_receive(:pre_index)
    Sector.should_receive(:find_layer3_sectors).and_return(:all_sectors)
    @client.should_receive(:index).with(:all_sectors)
    @client.should_receive(:post_index)

    @search.index_all
  end

  it "should pass delete_index on to the concrete client" do
    @client.should_receive(:delete_index)

    @search.delete_index
  end

  it "should pass search query on to concrete client" do
    s1 = FactoryGirl.create(:sector, public_id: 234)
    s2 = FactoryGirl.create(:sector, public_id: 123)

    @client.should_receive(:search).with(:query).and_return([123, 234])

    @search.search(:query).should eq([s2, s1])
  end
end