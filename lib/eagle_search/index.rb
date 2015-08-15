module EagleSearch
  class Index
    def initialize(klass, settings)
      @klass = klass
      @settings = settings
    end

    def create
      EagleSearch.client.indices.create index: index_name
    end

    private
    def index_name
      @settings[:index_name] || @klass.model_name.route_key
    end
  end
end
