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
        interpreter = EagleSearch::Interpreter.new(@index, term, options)
        search_response = EagleSearch.client.search index: eagle_search_index.alias_name, body: interpreter.payload
        EagleSearch::Response.new(self, search_response, options)
      end

      def reindex
        eagle_search_index.reindex
      end
    end

    module InstanceMethods
      def reindex
        index = self.class.eagle_search_index
        reindex_option = index.settings[:reindex]
        EagleSearch.client.index(
          index: index.alias_name,
          type: index.type_name,
          id: id,
          body: index_data
        ) if reindex_option.nil? || reindex_option
      end
    end
  end
end
