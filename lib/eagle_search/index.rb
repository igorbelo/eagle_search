module EagleSearch
  class Index
    def initialize(klass, settings)
      @klass = klass
      @settings = settings
    end

    def create
      EagleSearch.client.indices.create index: index_name, body: index_body
    end

    def delete
      EagleSearch.client.indices.delete index: index_name
    end

    private
    def index_name
      (@settings[:index_name] || @klass.model_name.route_key).downcase
    end

    def type_name
      @klass.model_name.param_key
    end

    def index_body
      { mappings: mappings }
    end

    def mappings
      base_mappings = {
        type_name => {
          properties: {}
        }
      }

      columns.select { |column| column.type == :string }.each do |column|
        base_mappings[type_name][:properties][column.name] = {}
        base_mappings[type_name][:properties][column.name][:type] = "string"
        base_mappings[type_name][:properties][column.name][:analyzer] = @settings[:language] if @settings[:language]
      end

      base_mappings
    end

    def columns
      @klass.columns
    end
  end
end
