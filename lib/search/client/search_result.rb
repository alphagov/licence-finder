class Search
  class Client
    class SearchResult
      attr_reader :raw_result

      def initialize(raw_result)
        @raw_result = raw_result
      end

      def public_id
        raw_result.dig("_source", "public_id")
      end
    end
  end
end
