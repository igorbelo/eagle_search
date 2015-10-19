module EagleSearch
  class Interpreter::Query
    attr_reader :payload

    def initialize(klass, query, options)
      case query
      when String
        if query == "*"
          @payload = { match_all: {} }
        else
          @payload = { multi_match: { query: query, type: "best_fields", fields: ["name"], tie_breaker: 0.3 } }
        end
      end
    end
  end
end
