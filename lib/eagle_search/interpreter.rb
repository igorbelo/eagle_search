module EagleSearch
  class Interpreter
    def initialize(klass, query, options)
      @query_payload = EagleSearch::Interpreter::Query.new(klass, query, options).payload

      @filter_payload =
        if options[:filters]
          EagleSearch::Interpreter::Filter.new(options[:filters]).payload
        elsif options[:custom_filters]
          options[:custom_filters]
        else
          {}
        end
    end

    def payload
      {
        query: {
          filtered: {
            query: @query_payload,
            filter: @filter_payload
          }
        }
      }
    end
  end
end
