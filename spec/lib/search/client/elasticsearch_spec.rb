require "spec_helper"
require "search/client/elasticsearch"

describe Search::Client::Elasticsearch do
  before(:each) do
    @es_config = {
        url:    'localhost',
        index:  'test-index',
        type:   'test-type',
        create: 'test-create'
    }
    @es_indexer = stub()
    Tire::Index.stubs(:new).returns(@es_indexer)
    @client = Search::Client::Elasticsearch.new(@es_config)
  end

  describe "initialization" do
    it "should initialize the indexer and searcher with the index name" do
      Tire::Index.expects(:new).with('test-index')
      Search::Client::Elasticsearch.new(@es_config)
    end
  end

  describe "indexing" do
    it "should delete and create index with mapping before re-indexing" do
      @es_indexer.expects(:delete)
      @es_indexer.expects(:create).with("test-create")
      @client.pre_index
    end

    it "should index provided sectors" do
      s1 = FactoryGirl.create(:sector, public_id: 1, name: "Sector One")
      s2 = FactoryGirl.create(:sector, public_id: 2, name: "Sector Two")
      s3 = FactoryGirl.create(:sector, public_id: 3, name: "Sector Three")
      indexing = sequence("indexing")
      @client.expects(:to_document).with(s1).returns(:doc1).in_sequence(indexing)
      @es_indexer.expects(:store).with(:doc1).in_sequence(indexing)
      @client.expects(:to_document).with(s2).returns(:doc2).in_sequence(indexing)
      @es_indexer.expects(:store).with(:doc2).in_sequence(indexing)
      @client.expects(:to_document).with(s3).returns(:doc3).in_sequence(indexing)
      @es_indexer.expects(:store).with(:doc3).in_sequence(indexing)

      @client.index [s1, s2, s3]
    end

    it "should convert a sector to a hash with the correct fields set" do
      document = @client.to_document(FactoryGirl.build(:sector, public_id: 123, name: "Test Sector"))
      document.should == {_id: 123, type: "test-type", public_id: 123, title: "Test Sector"}
    end

    it "should commit after re-indexing" do
      @es_indexer.expects(:refresh)
      @client.post_index
    end
  end

  describe "searching" do
    it "should search the title with a text query and just return ids" do
      d1 = stub()
      d1.expects(:public_id).returns(123)
      d2 = stub()
      d2.expects(:public_id).returns(234)
      response = stub()
      response.expects(:results).returns([d1, d2])

      Tire.expects(:search).with(@es_config[:index], {query: { text: { title: :query}}}).returns(response)
      @client.search(:query).should == [123, 234]
    end
  end
end