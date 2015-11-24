module EagleSearch
  class Interpreter
    def initialize(index, query, options)
      @index   = index
      @query   = query
      @options = options
      @options[:page] = @options[:page].to_i if @options[:page]
      @options[:per_page] = @options[:per_page].to_i if @options[:per_page]
    end

    def payload
      return @options[:custom_payload] if @options[:custom_payload]

      payload = {
        query: {
          filtered: {
            query: query_payload,
            filter: filter_payload
          }
        },
        aggregations: aggregations_payload
      }

      payload.merge!({ sort: @options[:sort] }) if @options[:sort]

      # from
      if @options[:page] && @options[:page] > 1
        from = (@options[:page] - 1) * (@options[:per_page] || 10)
        payload.merge!({ from: from })
      end

      #size
      payload.merge!({ size: @options[:per_page] }) if @options[:per_page]

      payload
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

    def aggregations_payload
      return {} unless @options[:aggregations]
      EagleSearch::Interpreter::Aggregation.new(@options[:aggregations]).payload
    end
  end
end
