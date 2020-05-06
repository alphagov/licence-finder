require "rails_helper"
require "search/client/elasticsearch"

RSpec.describe Search::Client::Elasticsearch do
  before(:each) do
    @index_name = "test-index"
    @es_config = {
      url: "localhost",
    }
    @client = Search::Client::Elasticsearch.new(
      index_name: @index_name,
      settings: "test-create",
      type: "test-type",
      config: @es_config,
    )
  end

  describe "indexing" do
    it "deletes and creates index with mapping before re-indexing" do
      allow_any_instance_of(
        Elasticsearch::API::Indices::IndicesClient,
      ).to receive(:delete).with(index: @index_name, ignore: [404])

      allow_any_instance_of(
        Elasticsearch::API::Indices::IndicesClient,
      ).to receive(:create).with(index: @index_name, body: /.*/).and_return(true)

      @client.pre_index
    end

    it "indexes provided sectors" do
      s1 = FactoryBot.create(:sector, public_id: 1, name: "Sector One")
      allow_any_instance_of(
        Elasticsearch::Transport::Client,
      ).to receive(:create).with(
        hash_including(@client.to_document(s1)),
      ).and_return(true)

      s2 = FactoryBot.create(:sector, public_id: 2, name: "Sector Two")
      allow_any_instance_of(
        Elasticsearch::Transport::Client,
      ).to receive(:create).with(
        hash_including(@client.to_document(s2)),
      ).and_return(true)

      s3 = FactoryBot.create(:sector, public_id: 3, name: "Sector Three")
      allow_any_instance_of(
        Elasticsearch::Transport::Client,
      ).to receive(:create).with(
        hash_including(@client.to_document(s3)),
      ).and_return(true)

      @client.index([s1, s2, s3])
    end

    it "converts a sector to a hash with the correct fields set" do
      document = @client.to_document(
        FactoryBot.build(
          :sector,
          public_id: 123,
          name: "Test Sector",
        ),
      )

      expect(document).to eq(
        id: 123,
        type: "test-type",
        body: {
          public_id: 123,
          title: "Test Sector",
          extra_terms: [],
          activities: [],
        },
      )
    end

    it "adds extra_terms to document when available" do
      allow(@client).to receive(:extra_terms).and_return(
        123 => %w[foo bar monkey],
      )
      document = @client.to_document(
        FactoryBot.build(
          :sector,
          public_id: 321,
          correlation_id: 123,
          name: "Test Sector",
        ),
      )

      expect(document).to eq(
        id: 321,
        type: "test-type",
        body: {
          public_id: 321,
          title: "Test Sector",
          extra_terms: %w[foo bar monkey],
          activities: [],
        },
      )
    end

    it "commits after re-indexing" do
      allow_any_instance_of(
        Elasticsearch::API::Indices::IndicesClient,
      ).to receive(:refresh).with(index: @index_name)

      @client.post_index
    end
  end

  describe "deleting" do
    it "deletes the index" do
      allow_any_instance_of(
        Elasticsearch::API::Indices::IndicesClient,
      ).to receive(:delete).with(index: @index_name, ignore: [404])

      @client.delete_index
    end
  end

  describe "searching" do
    it "searches the title with a text query and just returns ids" do
      es_response = {
        "hits" => {
          "hits" => [
            { "_source" => { "public_id" => 123 } },
            { "_source" => { "public_id" => 234 } },
          ],
        },
      }

      allow_any_instance_of(Elasticsearch::Transport::Client).to receive(:search).with(
        index: @index_name,
        body: {
          query: {
            multi_match: {
              fields: %w[title extra_terms activities],
              query: "query",
            },
          },
        },
      ).and_return(es_response)

      expect(@client.search("query")).to eq([123, 234])
    end
  end
end
