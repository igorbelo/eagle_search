require 'date'

module EagleSearch
  class Index
    attr_reader :settings, :alias_name

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

    def refresh
      EagleSearch.client.indices.refresh index: name
    end

    def info
      EagleSearch.client.indices.get index: name
    end

    def name
      @name ||= @settings[:index_name] || "#{ alias_name }_#{ DateTime.now.strftime('%Q') }"
    end

    def alias_name
      @alias_name ||= @settings[:index_name] || "#{ @klass.model_name.route_key.downcase }_#{ EagleSearch.env }"
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
      begin
        aliases = client.indices.get_alias name: alias_name
        client.indices.delete index: aliases.keys.join(",")
      rescue
        #do something
      ensure
        create
        bulk = []
        @klass.all.each do |record|
          bulk << { index: { _index: alias_name, _type: type_name, _id: record.id } }
          bulk << record.attributes
        end
        client.bulk body: bulk
      end
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

    private
    def body
      body = {
        mappings: mappings
      }
      body[:aliases] = { alias_name => {} } unless @settings[:index_name]
      body
    end

    def columns
      @klass.columns
    end
  end
end
