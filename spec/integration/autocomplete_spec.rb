require "spec_helper"

describe "autocomplete" do
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

  it "matches docs when searched by a fragment of word by default" do
    products = Product.search "neigh"
    expect(products.hits.map { |h| h["_source"]["name"] }).to eq(["Book: The Good Neighbor"])
  end

  it "does not match autocomplete when autocomplete option is false" do
    products = Product.search "neigh", autocomplete: false
    expect(products.total_hits).to eq(0)
  end
end
