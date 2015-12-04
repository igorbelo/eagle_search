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

    def each
      if block_given?
        records.each { |e| yield(e) }
      else
        records.to_enum
      end
    end

    def total_hits
      @response["hits"]["total"]
    end

    def hits
      @response["hits"]["hits"].each_with_index do |h, index|
        @response["hits"]["hits"][index]["highlight"] = Hash[h["highlight"].map { |field, value| [field, value.first] }] if @response["hits"]["hits"][index]["highlight"]
      end if @response["hits"]["hits"]
      @response["hits"]["hits"]
    end

    def aggregations
      @response["aggregations"]
    end

    def current_page
      @options[:page] || 1
    end

    def total_pages
      (total_hits / limit_value.to_f).ceil
    end

    def limit_value
      @options[:per_page] || 25
    end
  end
end
