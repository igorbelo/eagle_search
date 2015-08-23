module EagleSearch
  class Interpreter
    attr_reader :payload

    def initialize(query, options)
      query_payload = EagleSearch::Interpreter::Query.new(query).payload

      if options[:filters]
        filter_payload = EagleSearch::Interpreter::Filter.new(options[:filters]).payload
        @payload = { query: { filtered: { query: query_payload, filter: filter_payload } } }
      elsif options[:custom_filters]
        @payload = { query: { filtered: { query: query_payload, filter: options[:custom_filters] } } }
      else
        @payload = { query: query_payload }
      end
    end
  end
end
