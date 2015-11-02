module EagleSearch
  class Response
    def initialize(klass, response, options)
      @klass    = klass
      @response = response
      @options  = options
    end

    def records
      ids = hits.map { |hit| hit["_id"] }
      #avoids n+1
      @klass.includes(@options[:includes]) if @options[:includes]
      @klass.where(@klass.primary_key => ids)
    end

    def total_hits
      @response["hits"]["total"]
    end

    def hits
      @response["hits"]["hits"]
    end
  end
end
