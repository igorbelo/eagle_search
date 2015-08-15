require "eagle_search/version"
require "eagle_search/model"
require "eagle_search/index"
require "elasticsearch"

module EagleSearch
  def self.included(base)
    base.extend(EagleSearch::Model::ClassMethods)
  end

  def self.client
    @client ||= Elasticsearch::Client.new
  end
end
