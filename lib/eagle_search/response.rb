module EagleSearch
  class Response
    def initialize(response)
      @response = response
    end

    def total_hits
      @response["hits"]["total"]
    end

    def hits
      @response["hits"]["hits"]
    end
  end
end
