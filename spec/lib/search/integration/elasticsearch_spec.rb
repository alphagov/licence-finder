require "spec_helper"
require "search/client/elasticsearch"


describe Search::Client::Elasticsearch do
  before(:each) do
    s1 = FactoryGirl.create(:sector, :public_id => 123, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :public_id => 234, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :public_id => 345, :name => "Gooey Sector")

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
    @search.search("monkey")[0].public_id.should == 234
    @search.search("monkey").length.should == 1
  end
end