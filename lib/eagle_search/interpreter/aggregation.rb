module EagleSearch
  class Interpreter::Aggregation
    def initialize(aggregations)
      @aggregations = aggregations
    end

    def payload
      payload = {}
      case @aggregations
      when Array
        @aggregations.each do |aggregation|
          if aggregation.is_a?(String) || aggregation.is_a?(Symbol)
            payload[aggregation] = build_terms_aggregation(aggregation)
          end
        end
      end
      payload
    end

    private
    def build_terms_aggregation(field)
      {
        terms: {
          field: field
        }
      }
    end
  end
end
