module EagleSearch
  class Interpreter::Query

    def initialize(klass, query, options)
      @klass = klass
      @query = query
      @options = options
    end

    def payload
      case @query
      when String
        if @query == "*"
          { match_all: {} }
        else
          { multi_match: { query: query, type: "best_fields", fields: ["name"], tie_breaker: 0.3 } }
        end
      end
    end
  end
end
