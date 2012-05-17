class Search
  class Client
    class Elasticsearch
      def initialize(config)
        @config   = config
        @indexer  = Tire::Index.new(config[:index])
        @searcher = Tire::Search::Search.new(config[:index])
      end

      def pre_index
        @indexer.delete
        @indexer.create(@config[:create])
      end

      def index(sectors)
        @indexer.import sectors do |sector_chunk|
          sector_chunk.each { |sector| to_document sector }
        end
      end

      def post_index
        @indexer.refresh
      end

      def to_document(sector)
        {
          _id:  sector.public_id,
          type: @config[:type],
          public_id: sector.public_id,
          title: sector.name
        }
      end
    end
  end
end