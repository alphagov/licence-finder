class Search
  class Client
    class Elasticsearch
      def initialize(config)
        @config   = config
        @indexer  = Tire::Index.new(config[:index])

      end

      def delete_index
        @indexer.delete
      end

      def pre_index
        @indexer.delete
        @indexer.create(@config[:create])
      end

      def index(sectors)
        sectors.each do |sector|
          @indexer.store to_document(sector)
        end
      end

      def to_document(sector)
        {
          _id:  sector.public_id,
          type: @config[:type],
          public_id: sector.public_id,
          title: sector.name
        }
      end

      def post_index
        @indexer.refresh
      end

      def search(query)
        # this only returns public_ids to keep the public
        #interface as abstract as possible
        Tire.search(@config[:index], query: {
            text: {
                title: query
            }
        }).results.map(&:public_id)
      end
    end
  end
end