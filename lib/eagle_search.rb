require "eagle_search/version"
require "eagle_search/model"
require "eagle_search/index"
require "eagle_search/field"
require "eagle_search/query"
require "eagle_search/interpreter"
require "eagle_search/interpreter/query"
require "elasticsearch"

module EagleSearch
  def self.included(base)
    base.extend(EagleSearch::Model::ClassMethods)
  end

  def self.client
    @client ||= Elasticsearch::Client.new
  end
end
