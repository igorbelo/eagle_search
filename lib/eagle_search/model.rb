module EagleSearch
  class Model
    module ClassMethods
      def eagle_search(settings = {})
        @index = EagleSearch::Index.new(self, settings)
      end

      def eagle_search_index
        @index
      end

      def create_index
        eagle_search_index.create
      end

      def delete_index
        eagle_search_index.delete
      end

      def refresh_index
        eagle_search_index.refresh
      end

      def index_info
        eagle_search_index.info
      end

      def search(term, options = {})
        interpreter = EagleSearch::Interpreter.new(term, options)
        search_response = EagleSearch.client.search index: eagle_search_index.alias_name, body: interpreter.payload
        EagleSearch::Response.new(search_response)
      end

      def reindex
        eagle_search_index.reindex
      end
    end
  end
end
