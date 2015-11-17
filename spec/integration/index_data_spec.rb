require "spec_helper"

describe "custom settings" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false

      def index_data
        as_json only: [:name, :description]
      end
    end

    reindex_products
  end

  it "is expected only fields in #index_data method were indexed" do
    response = Product.search "*"
    response.hits.each do |hit|
      expect(hit["_source"].keys).to match_array(%w(name description))
    end
  end
end
