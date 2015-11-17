require "spec_helper"

describe "boost" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search

      def index_data
        as_json only: [:name, :description]
      end
    end

    Product.create(name: "The Good Neighbor", description: "The good house is a house which is warm on the winter.")
    Product.create(name: "The Good House", description: "The Good Neighbor is a neighbor who loves his neighbor.")
    reindex_products(create: false)
  end

  it "treats all fields with the same relevance" do
    response = Product.search "The Good Neighbor"
    hits = response.hits
    expect(hits[0]["_source"]["name"]).to eq("The Good Neighbor")
    expect(hits[1]["_source"]["name"]).to eq("The Good House")
  end

  it "gives more relevance to description" do
    response = Product.search "The Good Neighbor", fields: %w(name description^5)
    hits = response.hits
    expect(hits[0]["_source"]["name"]).to eq("The Good House")
    expect(hits[1]["_source"]["name"]).to eq("The Good Neighbor")
  end
end
