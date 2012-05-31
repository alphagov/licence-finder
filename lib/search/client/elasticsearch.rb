require "search/client"

class Search
  class Client
    class Elasticsearch < Search::Client
      def initialize(config)
        super
        @config   = config
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
        # this only returns public_ids to keep the public
        # interface as abstract as possible
        Tire.search(@config[:index], query: {
            query_string: {
                fields: %w(title extra_terms activities),
                query: query
            }
        }).results.map(&:public_id)
      end
    end
  end
end
