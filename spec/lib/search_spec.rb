require "search"

RSpec.describe Search do
  before(:each) do
    @client = double
    @search = Search.new(@client)
  end

  it "indexes all sectors with the configured client" do
    expect(@client).to receive(:pre_index)
    expect(Sector).to receive(:find_layer3_sectors).and_return(:all_sectors)
    expect(@client).to receive(:index).with(:all_sectors)
    expect(@client).to receive(:post_index)

    @search.index_all
  end

  it "passes delete_index on to the concrete client" do
    expect(@client).to receive(:delete_index)

    @search.delete_index
  end

  it "passes search query on to concrete client" do
    s1 = FactoryGirl.create(:sector, public_id: 234)
    s2 = FactoryGirl.create(:sector, public_id: 123)

    expect(@client).to receive(:search).with(:query).and_return([123, 234])

    expect(@search.search(:query)).to eq([s2, s1])
  end
end
