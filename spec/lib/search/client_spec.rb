require "spec_helper"
require "search/client"

RSpec.describe Search::Client do
  it "generates the extra terms path" do
    client = Search::Client.new(extra_terms_filename: "extra-terms.csv")
    expect(client.extra_terms_path.to_s).to match(%r{data/extra-terms\.csv$})
  end

  it "allows no extra terms to be provided" do
    client = Search::Client.new
    expect(client.extra_terms).to eq(Hash.new)
  end

  it "returns an empty array if no extra terms are found for a sector" do
    client = Search::Client.new
    expect(client.extra_terms_for_sector(FactoryGirl.build(:sector, :public_id => 123))).to eq([])
  end


  describe "with a stubbed out path" do
    before(:each) do
      source = StringIO.new(<<-END)
123,foo, bar, monkey
321,bottle, mouse, keyboard
      END
      @client = Search::Client.new()
      allow(@client).to receive(:extra_terms_handle).and_return(source)
    end

    it "provides extra terms" do
      expect(@client.extra_terms).to eq({
          123 => %w{foo bar monkey},
          321 => %w{bottle mouse keyboard}
      })
    end

    it "finds extra terms for a sector" do
      sector = FactoryGirl.build(:sector, :public_id => 321, :correlation_id => 123)
      expect(@client.extra_terms_for_sector(sector)).to eq(%w(foo bar monkey))
    end
  end
end
