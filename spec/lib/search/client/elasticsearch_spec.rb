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
    @es_searcher = stub()
    Tire::Search::Search.stubs(:new).returns(@es_searcher)
    @client = Search::Client::Elasticsearch.new(@es_config)
  end

  describe "initialization" do
    it "should initialize the indexer and searcher with the index name" do
      Tire::Index.expects(:new).with('test-index')
      Tire::Search::Search.expects(:new).with('test-index')
      Search::Client::Elasticsearch.new(@es_config)
    end
  end

  describe "indexing" do
    it "should delete and create index with mapping before re-indexing" do
      @es_indexer.expects(:delete)
      @es_indexer.expects(:create).with("test-create")
      @client.pre_index
    end

    # Warning this is not very well tested!
    it "should index provided sectors" do
      @es_indexer.expects(:import).with(:some_sectors)
      @client.index(:some_sectors)
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
end