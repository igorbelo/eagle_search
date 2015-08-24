module EagleSearch
  class Index
    attr_reader :settings

    def initialize(klass, settings)
      @klass = klass
      @settings = settings
    end

    def create
      EagleSearch.client.indices.create index: name, body: index_body
    end

    def delete
      EagleSearch.client.indices.delete index: name
    end

    def name
      @name ||= (@settings[:index_name] || @klass.model_name.route_key).downcase
    end

    def type_name
      if @settings[:mappings]
        @settings[:mappings].keys.first.downcase
      else
        @klass.model_name.param_key
      end
    end

    private
    def index_body
      { mappings: mappings }
    end

    def mappings
      if @settings[:mappings]
        @settings[:mappings]
      else
        base_mappings = {
          type_name => {
            properties: {}
          }
        }

        columns.each do |column|
          base_mappings[type_name][:properties][column.name] = EagleSearch::Field.new(self, column).mapping
        end

        base_mappings
      end
    end

    def columns
      @klass.columns
    end
  end
end
