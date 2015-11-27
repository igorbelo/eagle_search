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
        return { aggregation => build_terms_aggregation(aggregation) }
      elsif aggregation.is_a?(Array)
        aggregation.each do |agg|
          payload.merge!(build_aggregation(agg))
        end
      elsif aggregation.is_a?(Hash)
        aggregation.each do |field_name, aggregation_body|
          if stats_aggregation?(aggregation_body)
            payload.merge!({ field_name => build_stats_aggregation(field_name) })
          elsif range_aggregation?(aggregation_body)
            payload.merge!({ field_name => build_range_aggregation(field_name, aggregation_body) })
          else
            payload.merge!(build_aggregation(field_name))
            payload[field_name].merge!(aggregations: build_aggregation(aggregation_body))
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

    def build_range_aggregation(field, range_aggregation)
      agg = {
        range: {
          field: field,
          ranges: []
        }
      }

      range_aggregation[:ranges].each do |range|
        if range.is_a?(Range)
          agg[:range][:ranges] << {
            from: range.min,
            to: range.max
          }
        else
          agg[:range][:ranges] << range
        end
      end

      agg
    end

    def stats_aggregation?(aggregation)
      aggregation.is_a?(Hash) && aggregation[:type] == "stats"
    end

    def terms_aggregation?(aggregation)
      aggregation.is_a?(Symbol) || aggregation.is_a?(String)
    end

    def range_aggregation?(aggregation)
      aggregation.is_a?(Hash) && aggregation[:ranges]
    end
  end
end
