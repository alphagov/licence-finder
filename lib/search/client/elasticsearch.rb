class Search
  class Client
    class Elasticsearch < Search::Client
      attr_accessor :client, :index_name, :settings, :type

      def initialize(index_name:, settings:, type:, config:)
        super(config)
        @index_name = index_name
        @settings = settings
        @type = type
        @config = config
        @client = ::Elasticsearch::Client.new(config)
      end

      def delete_index
        client.indices.delete(index: index_name, ignore: [404])
      end

      def pre_index
        delete_index
        index = client.indices.create(
          index: index_name,
          body: settings,
        )
        raise unless index

        index
      end

      def index(sectors)
        sectors.each do |sector|
          client.create(
            { index: index_name }.merge(to_document(sector)),
          )
        end
      end

      def to_document(sector)
        {
          id: sector.public_id,
          type: type,
          body: {
            public_id: sector.public_id,
            title: sector.name,
            extra_terms: extra_terms_for_sector(sector),
            activities: activities_for_sector(sector),
          },
        }
      end

      def post_index
        client.indices.refresh(index: index_name)
      end

      def search(query)
        raw_search_results = client.search(
          index: index_name,
          body: {
            query: {
              multi_match: {
                fields: %w[title extra_terms activities],
                query: query,
              },
            },
          },
        )

        raw_search_results["hits"]["hits"].map do |result|
          SearchResult.new(result).public_id
        end
      end
    end
  end
end
