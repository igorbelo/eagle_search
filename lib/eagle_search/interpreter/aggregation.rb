module EagleSearch
  class Interpreter::Aggregation
    def initialize(aggregations)
      @aggregations = aggregations
    end

    def payload
      @payload ||= build_aggregation(@aggregations)
    end

    private
    def build_aggregation(aggregation)
      payload = {}

      if terms_aggregation?(aggregation)
        payload[aggregation] = build_terms_aggregation(aggregation)
      elsif aggregation.is_a?(Array)
        aggregation.each do |agg|
          payload.merge!(build_aggregation(agg))
        end
      elsif aggregation.is_a?(Hash)
        field_name, aggregation_body = aggregation.first
        if stats_aggregation?(aggregation_body)
          payload = { field_name => build_stats_aggregation(field_name) }
        else
          aggregation.each do |key, value|
            payload.merge!(build_aggregation(key))
            payload[key].merge!(aggregations: build_aggregation(value))
          end
        end
      end

      payload
    end

    def build_terms_aggregation(field)
      {
        terms: {
          field: field
        }
      }
    end

    def build_stats_aggregation(field)
      {
        stats: {
          field: field
        }
      }
    end

    def stats_aggregation?(aggregation)
      aggregation.is_a?(Hash) && aggregation[:type] == "stats"
    end

    def terms_aggregation?(aggregation)
      aggregation.is_a?(Symbol) || aggregation.is_a?(String)
    end
  end
end
