module EagleSearch
  class Interpreter::Filter
    attr_reader :payload

    LOGICAL_OPERATORS = { and: :must, not: :must_not, or: :should }

    def initialize(filters)
      @payload = { bool: {} }
      @filters = filters

      @filters.each do |key, value|
        key = key.to_sym

        if LOGICAL_OPERATORS.keys.include?(key)
          bool_filter_key = LOGICAL_OPERATORS[key]

          if value.is_a?(Hash)
            value.each { |field, field_value| add_bool_filter(bool_filter_key, field, field_value) }
          else
            value.each do |filters|
              filters.each do |field, field_value|
                add_bool_filter(bool_filter_key, field, field_value)
              end
            end
          end
        else
          add_bool_filter(:must, key, value)
        end
      end
    end

    private
    def add_bool_filter(bool_filter_key, field, value)
      @payload[:bool][bool_filter_key] ||= []
      @payload[:bool][bool_filter_key] << elasticsearch_filter_hash(field, value)
    end

    def elasticsearch_filter_hash(field, field_value)
      case field_value
      when Array
        { terms: { field => field_value } }
      else
        { term: { field => field_value } }
      end
    end
  end
end
