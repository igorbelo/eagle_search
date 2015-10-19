require 'date'

module EagleSearch
  class Index
    attr_reader :settings, :alias_name
    delegate :columns, to: :klass

    def initialize(klass, settings)
      @klass = klass
      @settings = settings
    end

    def create
      EagleSearch.client.indices.create index: name, body: body
    end

    def delete
      EagleSearch.client.indices.delete index: alias_name
    end

    def refresh
      EagleSearch.client.indices.refresh index: alias_name
    end

    def info
      EagleSearch.client.indices.get index: alias_name
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
          bulk << record.index_data
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
        mappings: mappings,
        aliases: { alias_name => {} },
        settings: {
          analysis: analysis_settings
        }
      }
      body[:settings][:number_of_shards] = 1 if EagleSearch.env == "test" || EagleSearch.env == "development"
      body
    end

    def analysis_settings
      {
        filter: {
          eagle_search_shingle_filter: {
            type: "shingle",
            min_shingle_size: 2,
            max_shingle_size: 2,
            output_unigrams: false
          }
        },
        analyzer: {
          eagle_search_shingle_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: [
              "lowercase",
              "eagle_search_shingle_filter"
            ]
          }
        }
      }
    end

    def klass
      @klass
    end
  end
end
