require "search/client"
require 'search/client/search_result'
require 'elasticsearch'

class Search
  class Client
    class Elasticsearch < Search::Client
      attr_accessor :client, :index_name, :settings, :type
      ESCAPE_LUCENE_CHARS = /
        ( [-+!\(\)\{\}\[\]^"~*?:\\] # A special character
          | &&                        # Boolean &&
          | \|\|                      # Boolean ||
        )/x

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
          body: settings
        )
        raise unless index

        index
      end

      def index(sectors)
        sectors.each do |sector|
          client.create(
            { index: index_name }.merge(to_document(sector))
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
            activities: activities_for_sector(sector)
          }
        }
      end

      def post_index
        client.indices.refresh(index: index_name)
      end

      def search(query)
        return [] if query.match(ESCAPE_LUCENE_CHARS) && query.length <= 2

        query = escape_lucene_chars(query)

        raw_search_results = client.search(
          index: index_name,
          q: query,
          fields: %w(public_id title extra_terms activities),
          sort: '_score:desc',
        )

        raw_search_results['hits']['hits'].map do |result|
          SearchResult.new(result).public_id
        end
      end

      # The Lucene documentation declares special characters to be:
      #   + - && || ! ( ) { } [ ] ^ " ~ * ? : \
      def escape_lucene_chars(s)
        s.gsub(ESCAPE_LUCENE_CHARS) { |char| "\\#{char}" }
      end

      def downcase_ending_keywords(s)
        escape_keywords_regex = /(AND$ | OR$ | NOT$)/x
        s.gsub(escape_keywords_regex, &:downcase)
      end
    end
  end
end
