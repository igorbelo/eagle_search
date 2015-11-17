require "spec_helper"

describe "exact match fields" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false, exact_match_fields: [:name]

      def index_data
        as_json only: [:name, :description]
      end
    end

    reindex_products
  end

  context "searching" do
    it "matches when searched by exact term" do
      response = Product.search "Book: The Good Neighbor"
      expect(response.total_hits).to eq(1)
      expect(response.hits.first["_source"]["name"]).to eq("Book: The Good Neighbor")
    end

    it "does not match when not searched by exact term" do
      response = Product.search "The Good Neighbor"
      expect(response.total_hits).to eq(0)
    end
  end

  context "filtering" do
    it "matches when filtered by exact term" do
      response = Product.search "*", filters: { name: "Book: The Good Neighbor" }
      expect(response.total_hits).to eq(1)
      expect(response.hits.first["_source"]["name"]).to eq("Book: The Good Neighbor")
    end

    it "does not match when not filtered by exact term" do
      response = Product.search "*", filters: { name: "The Good Neighbors" }
      expect(response.total_hits).to eq(0)
    end
  end
end
