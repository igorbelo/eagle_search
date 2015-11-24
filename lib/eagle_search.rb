require "eagle_search/version"
require "eagle_search/model"
require "eagle_search/index"
require "eagle_search/field"
require "eagle_search/response"
require "eagle_search/interpreter"
require "eagle_search/interpreter/query"
require "eagle_search/interpreter/filter"
require "eagle_search/interpreter/aggregation"
require "elasticsearch"

module EagleSearch
  def self.included(base)
    base.extend(EagleSearch::Model::ClassMethods)
    base.include(EagleSearch::Model::InstanceMethods)
    base.after_commit :reindex, on: [:create, :update]
  end

  def self.client
    @client ||= Elasticsearch::Client.new
  end

  def self.env
    @env ||= ENV['RAILS_ENV'] || "development"
  end
end
