module EagleSearch
  class Interpreter::Query

    def initialize(index, query, options)
      @index = index
      @query = query
      @options = options
    end

    def payload
      case @query
      when String
        if @query == "*"
          { match_all: {} }
        else
          query_payload
        end
      end
    end

    private
    def properties
      @index.mappings[@index.type_name][:properties]
    end

    def analyzed_properties
      properties.select { |field_name, field_hash| field_hash[:type] == "string" && field_hash[:index] == "analyzed" }
    end

    def not_analyzed_properties
      properties.select { |field_name, field_hash| field_hash[:type] == "string" && field_hash[:index] == "not_analyzed" }
    end

    def query_payload
      @query_payload = {}
      build_multi_match_query
      build_match_queries
      build_term_queries
      @query_payload
    end

    def build_multi_match_query
      if analyzed_properties
        @query_payload = {
          bool: {
            should: []
          }
        }

        @query_payload[:bool][:should] << {
          multi_match: {
            query: @query,
            fields: @options[:fields] || analyzed_properties.keys,
            tie_breaker: 0.3
          }
        }
      end
    end

    def build_match_queries
      return unless analyzed_properties

      match_queries = []
      analyzed_properties.keys.each do |field_name|
        match_queries << {
          match: {
            "#{ field_name }.shingle" => @query
          }
        }
      end

      payload = {
        bool: {
          should: match_queries
        }
      }

      @query_payload[:bool] ? @query_payload[:bool][:should] << payload : @query_payload[:bool][:should] = payload
    end

    def build_term_queries
      return unless not_analyzed_properties

      term_queries = []
      not_analyzed_properties.keys.each do |field_name|
        term_queries << {
          term: {
            field_name => @query
          }
        }
      end

      payload = {
        bool: {
          should: term_queries
        }
      }

      if @query_payload[:bool]
        @query_payload[:bool][:should][1][:bool][:should] << payload
      else
        @query_payload = payload
      end
    end
  end
end
