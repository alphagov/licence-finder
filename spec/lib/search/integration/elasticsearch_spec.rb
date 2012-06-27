require "spec_helper"
require "search/client/elasticsearch"


describe Search::Client::Elasticsearch do
  before(:each) do
    WebMock.allow_net_connect!
    $search = Search.create_for_config("elasticsearch", "test")

    s1 = FactoryGirl.create(:sector, :public_id => 123, :name => "Fooey Sector", :layer => 3)
    s2 = FactoryGirl.create(:sector, :public_id => 234, :name => "Kablooey Sector", :layer => 3)
    s3 = FactoryGirl.create(:sector, :public_id => 345, :name => "Gooey Sector", :layer => 3)
    s4 = FactoryGirl.create(:sector, :public_id => 456, :name => "Something else", :layer => 3)
    a1 = FactoryGirl.create(:activity, :public_id => 7123, :name => "Fooey activity", :sectors => [s2])
    a2 = FactoryGirl.create(:activity, :public_id => 7124, :name => "Unrelated terms", :sectors => [s3])

    @search = $search.clone
    @search.client.stubs(:extra_terms).returns({
      123 => %w(foo bar),
      234 => %w(monkey)
    })
    @search.index_all
  end

  after(:each) do
    @search.delete_index
  end

  it "should return sectors that match on title" do
    @search.search("fooey")[0].public_id.should == 123
    @search.search("sector").length.should == 3
  end

  it "should return sectors that match on extra terms" do
    search = @search.search("monkey")
    search[0].public_id.should == 234
    search.length.should == 1
  end

  it "should return sectors that match on activities" do
    search = @search.search("unrelated")
    search[0].public_id.should == 345
    search.length.should == 1
  end

  it "should return sectors above activities when both match" do
    search = @search.search("fooey")
    search.length.should == 2
    search[0].public_id.should == 123
  end
end
