module EagleSearch
  class Index
    attr_reader :settings

    def initialize(klass, settings)
      @klass = klass
      @settings = settings
    end

    def create
      EagleSearch.client.indices.create index: name, body: body
    end

    def delete
      EagleSearch.client.indices.delete index: name
    end

    def name
      @name ||= alias_name + "_#{ Time.now.to_i }"
    end

    def alias_name
      @alias_name ||= (@settings[:index_name] || @klass.model_name.route_key).downcase
    end

    def type_name
      if @settings[:mappings]
        @settings[:mappings].keys.first.downcase
      else
        @klass.model_name.param_key
      end
    end

    def reindex
      client = EagleSearch.client
      aliases = client.indices.get_alias name: alias_name
      create
      client.indices.delete index: aliases.keys.join(",")
      bulk = []
      all.each do |record|
        bulk << { index: { _index: @index.alias_name, _type: @index.type_name, _id: record.id } }
        bulk << record.attributes
      end
      client.bulk body: bulk
    end

    private
    def body
      {
        aliases: {
          alias_name => {}
        },
        mappings: mappings
      }
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
