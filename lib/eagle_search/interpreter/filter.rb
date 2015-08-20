module EagleSearch
  class Interpreter::Filter
    attr_reader :payload

    def initialize(filters)
      @payload = {}
    end
  end
end
