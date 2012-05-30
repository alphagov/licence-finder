require "spec_helper"
require "search/client"

describe Search::Client do
  it "should generate the extra terms path" do
    client = Search::Client.new(extra_terms_filename: "extra-terms.csv")
    client.extra_terms_path.to_s.should =~ %r{data/extra-terms\.csv$}
  end

  it "should allow no extra terms to be provided" do
    client = Search::Client.new
    client.extra_terms.should == Hash.new
  end

  it "should return an empty array if no extra terms are found for a sector" do
    client = Search::Client.new
    client.extra_terms_for_sector(FactoryGirl.build(:sector, :public_id => 123)).should == []
  end


  describe "with a stubbed out path" do
    before(:each) do
      source = StringIO.new(<<-END)
123,foo, bar, monkey
321,bottle, mouse, keyboard
      END
      @client = Search::Client.new()
      @client.stubs(:extra_terms_handle).returns(source)
    end

    it "should provide extra terms" do
      @client.extra_terms.should == {
          123 => %w{foo bar monkey},
          321 => %w{bottle mouse keyboard}
      }
    end

    it "should find extra terms for a sector" do
      sector = FactoryGirl.build(:sector, :public_id => 123)
      @client.extra_terms_for_sector(sector).should == %w(foo bar monkey)
    end
  end
end