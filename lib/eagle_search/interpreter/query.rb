module EagleSearch
  class Interpreter::Query
    attr_reader :payload

    def initialize(query)
      if query == "*"
        @payload = { match_all: {} }
      end
    end
  end
end
