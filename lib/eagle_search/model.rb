module EagleSearch
  class Model
    module ClassMethods
      def eagle_search(settings = {})
        @index = EagleSearch::Index.new(self, settings)
      end

      def create_index
        @index.create
      end

      def search(term, options = {})
        interpreter = EagleSearch::Interpreter.new(term, options)
        search_response = EagleSearch.client.search index: @index.name, body: interpreter.payload
        EagleSearch::Response.new(search_response)
      end
    end
  end
end
