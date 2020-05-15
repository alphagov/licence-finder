require "rails_helper"
require "search"

RSpec.describe Search do
  before(:each) do
    @client = double
    allow(Search.instance).to receive(:client).and_return(@client)
  end

  it "indexes all sectors with the configured client" do
    expect(@client).to receive(:pre_index)
    expect(Sector).to receive(:find_layer3_sectors).and_return(:all_sectors)
    expect(@client).to receive(:index).with(:all_sectors)
    expect(@client).to receive(:post_index)

    Search.instance.index_all
  end

  it "passes delete_index on to the concrete client" do
    expect(@client).to receive(:delete_index)

    Search.instance.delete_index
  end

  it "passes search query on to concrete client" do
    s1 = FactoryBot.create(:sector, public_id: 234)
    s2 = FactoryBot.create(:sector, public_id: 123)

    expect(@client).to receive(:search).with(:query).and_return([123, 234])

    expect(Search.instance.search(:query)).to eq([s2, s1])
  end
end
