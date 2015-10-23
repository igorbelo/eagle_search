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
      if analyzed_properties
        payload = {
          bool: {
            should: [
              {
                multi_match: {
                  query: @query,
                  fields: @options[:fields] || analyzed_properties.keys,
                  tie_breaker: 0.3
                }
              },
              {
                bool: {
                  should: []
                }
              }
            ]
          }
        }

        #shingle for analyzed properties
        analyzed_properties.keys.each do |field_name|
          payload[:bool][:should][1][:bool][:should] << {
            match: {
              "#{ field_name }.shingle" => @query
            }
          }
        end
      end

      payload
    end
  end
end
