module EagleSearch
  class Interpreter
    def initialize(index, query, options)
      @index   = index
      @query   = query
      @options = options
    end

    def payload
      return @options[:custom_payload] if @options[:custom_payload]

      {
        query: {
          filtered: {
            query: query_payload,
            filter: filter_payload
          }
        }
      }
    end

    private
    def query_payload
      if @options[:custom_query]
        @options[:custom_query]
      else
        EagleSearch::Interpreter::Query.new(@index, @query, @options).payload
      end
    end

    def filter_payload
      if @options[:filters]
        EagleSearch::Interpreter::Filter.new(@options[:filters]).payload
      elsif @options[:custom_filters]
        @options[:custom_filters]
      else
        {}
      end
    end
  end
end
