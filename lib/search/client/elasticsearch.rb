require "search/client"

class Search
  class Client
    class Elasticsearch < Search::Client
      ESCAPE_LUCENE_CHARS = /
        ( [-+!\(\)\{\}\[\]^"~*?:\\] # A special character
          | &&                        # Boolean &&
          | \|\|                      # Boolean ||
        )/x

      def initialize(config)
        super
        @config = config
        configure
      end

      def configure
        url = @config[:url]
        Tire.configure { url url }
        logger = @config[:logger]
        if logger
          Tire.configure { logger logger }
        end
      end

      def indexer
        return @indexer unless @indexer.nil?
        @indexer = Tire::Index.new(@config[:index])
      end

      def delete_index
        indexer.delete
      end

      def pre_index
        indexer.delete
        raise unless indexer.create(@config[:create])
      end

      def index(sectors)
        sectors.each do |sector|
          indexer.store to_document(sector)
        end
      end

      def to_document(sector)
        {
          _id:  sector.public_id,
          type: @config[:type],
          public_id: sector.public_id,
          title: sector.name,
          extra_terms: extra_terms_for_sector(sector),
          activities: activities_for_sector(sector)
        }
      end

      def post_index
        indexer.refresh
      end

      def search(query)
        return [] if query.match(ESCAPE_LUCENE_CHARS) && query.length <= 2

        query = escape_lucene_chars(query)

        # this only returns public_ids to keep the public
        # interface as abstract as possible
        Tire.search(@config[:index], query: {
            query_string: {
                fields: %w(title extra_terms activities),
                query: query
            }
        }).results.map(&:public_id)
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
