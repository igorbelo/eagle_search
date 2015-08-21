module EagleSearch
  class Interpreter
    attr_reader :payload

    def initialize(query, options)
      query_payload = EagleSearch::Interpreter::Query.new(query).payload

      if options[:filters]
        filter_payload = EagleSearch::Interpreter::Filter.new(options[:filters]).payload
        @payload = { query: { filtered: { query: query_payload, filter: filter_payload } } }
      else
        @payload = { query: query_payload }
      end
    end
  end
end
