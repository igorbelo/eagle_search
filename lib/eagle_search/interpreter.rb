module EagleSearch
  class Interpreter
    attr_reader :payload

    def initialize(query, options)
      query_payload = EagleSearch::Interpreter::Query.new(query).payload

      if options[:filters]
        @payload = { query: { filtered: { query: query_payload, filter: {} } } }
      else
        @payload = { query: query_payload }
      end
    end
  end
end
