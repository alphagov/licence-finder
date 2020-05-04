require "rails_helper"
require "search/client/elasticsearch"

RSpec.describe Search::Client::Elasticsearch do
  before(:each) do
    WebMock.allow_net_connect!
    $search = Search.create

    FactoryBot.create(:sector, public_id: 123, correlation_id: 987, name: "Fooey Sector", layer: 3)
    s2 = FactoryBot.create(:sector, public_id: 234, correlation_id: 986, name: "Kablooey Sector", layer: 3)
    s3 = FactoryBot.create(:sector, public_id: 345, correlation_id: 985, name: "Gooey Sector", layer: 3)
    FactoryBot.create(:sector, public_id: 456, correlation_id: 984, name: "Something else", layer: 3)
    FactoryBot.create(:activity, public_id: 7123, correlation_id: 983, name: "Fooey activity", sectors: [s2])
    FactoryBot.create(:activity, public_id: 7124, correlation_id: 982, name: "Unrelated terms", sectors: [s3])

    @search = $search.clone
    allow(@search.client).to receive(:extra_terms).and_return(987 => %w[foo bar],
                                                              986 => %w[monkey])
    @search.index_all
  end

  after(:each) do
    @search.delete_index
  end

  it "returns sectors that match on title" do
    expect(@search.search("fooey")[1].public_id).to eq(123)
    expect(@search.search("sector").length).to eq(3)
  end

  it "returns sectors that match on extra terms" do
    search = @search.search("monkey")
    expect(search[0].public_id).to eq(234)
    expect(search.length).to eq(1)
  end

  it "returns sectors that match on activities" do
    search = @search.search("unrelated")
    expect(search[0].public_id).to eq(345)
    expect(search.length).to eq(1)
  end

  it "returns sectors above activities when both match" do
    search = @search.search("fooey")
    expect(search.length).to eq(2)
    expect(search[1].public_id).to eq(123)
  end
end
