module EagleSearch
  class Interpreter::Filter
    attr_reader :payload

    LOGICAL_OPERATORS = { and: :must, not: :must_not, or: :should }

    def initialize(filters)
      @filters = filters
    end

    def payload
      @payload ||= generate_payload(@filters)
    end

    private
    def generate_payload(filters)
      payload = {}

      filters.each do |key, value|
        key = key.to_sym

        if LOGICAL_OPERATORS.include?(key)
          payload = { bool: { LOGICAL_OPERATORS[key] => [] } }

          if value.is_a?(Array)
            value.each { |filter| payload[:bool][LOGICAL_OPERATORS[key]] << generate_payload(filter) }
          else
            value.each { |field, field_value| payload[:bool][LOGICAL_OPERATORS[key]] << generate_payload({ field => field_value }) }
          end
        else
          payload = elasticsearch_filter_hash(key, value)
        end
      end

      payload
    end

    def elasticsearch_filter_hash(field, field_value)
      case field_value
      when Array
        { terms: { field => field_value } }
      when Hash
        if field_value.keys.any? { |key| %i(lt gt lte gte).include?(key.to_sym) }
          { range: { field => field_value } }
        end
      when Range
        { range: { field => { gte: field_value.min, lte: field_value.max } } }
      when Regexp
        { regexp: { field => field_value.source } }
      when nil
        { missing: { field: field } }
      else
        { term: { field => field_value } }
      end
    end
  end
end
