class Search
  class Client
    class SearchResult
      attr_reader :raw_result

      def initialize(raw_result)
        @raw_result = raw_result
      end

      def public_id
        public_id_result = raw_result.dig('fields', 'public_id') || []

        public_id_result.first
      end
    end
  end
end
