require "search/client/elasticsearch"

RSpec.describe Search::Client::Elasticsearch do
  before(:each) do
    @es_config = {
        url:    'localhost',
        index:  'test-index',
        type:   'test-type',
        create: 'test-create'
    }
    @es_indexer = double()
    @client = Search::Client::Elasticsearch.new(@es_config)
    allow(@client).to receive(:indexer).and_return(@es_indexer)
  end

  describe "indexing" do
    it "deletes and creates index with mapping before re-indexing" do
      expect(@es_indexer).to receive(:delete)
      expect(@es_indexer).to receive(:create).with("test-create").and_return(true)
      @client.pre_index
    end

    it "indexes provided sectors" do
      s1 = FactoryGirl.create(:sector, public_id: 1, name: "Sector One")
      s2 = FactoryGirl.create(:sector, public_id: 2, name: "Sector Two")
      s3 = FactoryGirl.create(:sector, public_id: 3, name: "Sector Three")
      # indexing = sequence("indexing")
      expect(@client).to receive(:to_document).with(s1).and_return(:doc1)
      expect(@es_indexer).to receive(:store).with(:doc1)
      expect(@client).to receive(:to_document).with(s2).and_return(:doc2)
      expect(@es_indexer).to receive(:store).with(:doc2)
      expect(@client).to receive(:to_document).with(s3).and_return(:doc3)
      expect(@es_indexer).to receive(:store).with(:doc3)

      @client.index [s1, s2, s3]
    end

    it "converts a sector to a hash with the correct fields set" do
      document = @client.to_document(FactoryGirl.build(:sector, public_id: 123, name: "Test Sector"))
      expect(document).to eq({_id: 123, type: "test-type", public_id: 123, title: "Test Sector", extra_terms: [], activities: []})
    end

    it "adds extra_terms to document when available" do
      allow(@client).to receive(:extra_terms).and_return({123 => %w(foo bar monkey)})
      document = @client.to_document(FactoryGirl.build(:sector, public_id: 321, correlation_id: 123, name: "Test Sector"))
      expect(document).to eq({_id: 321, type: "test-type", public_id: 321, title: "Test Sector", extra_terms: %w(foo bar monkey), activities: []})
    end

    it "commits after re-indexing" do
      expect(@es_indexer).to receive(:refresh)
      @client.post_index
    end
  end

  describe "deleting" do
    it "deletes the index" do
      expect(@es_indexer).to receive(:delete)

      @client.delete_index
    end
  end

  describe "searching" do
    it "searches the title with a text query and just returns ids" do
      d1 = double()
      expect(d1).to receive(:public_id).and_return(123)
      d2 = double()
      expect(d2).to receive(:public_id).and_return(234)
      response = double()
      expect(response).to receive(:results).and_return([d1, d2])

      expect(Tire).to receive(:search).with(@es_config[:index], {
          query: {
              query_string: {
                  fields: %w(title extra_terms activities),
                  query: "query"
              }
          }
      }).and_return(response)
      expect(@client.search("query")).to eq([123, 234])
    end
  end

  describe "Lucene search escaping characters" do
    it "returns valid strings back" do
      expect(@client.escape_lucene_chars("blargh")).to eq("blargh")
      expect(@client.escape_lucene_chars("Testing")).to eq("Testing")
    end

    it "removes expected special chars" do
      %w(+ - && || ! ( ) { } [ ] ^ " ~ * ? \ :).each { |char|
        char.strip!
        expect(@client.escape_lucene_chars("#{char}blargh")).to eq("\\#{char}blargh")
      }
    end

    it "downcases search keywords" do
      expect(@client.downcase_ending_keywords("bleh AND")).to eq("bleh and")
      expect(@client.downcase_ending_keywords("bleh OR")).to eq("bleh or")
      expect(@client.downcase_ending_keywords("bleh NOT")).to eq("bleh not")
    end
  end
end
