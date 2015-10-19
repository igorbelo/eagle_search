require "spec_helper"

describe "filtering" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search

      def index_data
        as_json only: [:id, :available_stock, :created_at, :updated_at, :active, :name, :description, :sale_price, :list_price]
      end
    end

    reindex_products
  end

  context "by name" do
    it "matches 2 documents when filter matches by name" do
      response = Product.search("*", filters: { name: "book" })
      expect(response.total_hits).to eq 2
    end

    it "does not match any document when filter does not match by name" do
      response = Product.search("*", filters: { name: "i'm not in a document" })
      expect(response.total_hits).to eq 0
    end

    it "matches only 'Book: The Good Neighbor' product when filtering by name = 'neighbor'" do
      response = Product.search("*", filters: { name: "neighbor" })
      source = response.hits.first["_source"]
      expect(response.total_hits).to eq 1
      expect(source["name"]).to eq "Book: The Good Neighbor"
    end
  end

  context "by multiple fields" do
    it "matches only 'Book: The Good Neighbor' product when filtering by name = 'neighbor' and active products" do
      response = Product.search("*", filters: { and: { name: "neighbor", active: true } })
      source = response.hits.first["_source"]
      expect(response.total_hits).to eq 1
      expect(source["name"]).to eq "Book: The Good Neighbor"
    end

    it "matches only 'Book: The Hidden Child' product when filtering by available_stock = true and inactive products" do
      response = Product.search("*", filters: { and: { active: false } })
      source = response.hits.first["_source"]
      expect(response.total_hits).to eq 1
      expect(source["name"]).to eq "Book: The Hidden Child"
    end
  end

  context "range filters" do
    it "matches products with sale_price greather or equal than 4.99" do
      response = Product.search("*", filters: { sale_price: { gte: 4.99 } })
      expect(response.total_hits).to eq 3
    end

    it "matches products with sale_price greather than 4.99" do
      response = Product.search("*", filters: { sale_price: { gt: 4.99 } })
      expect(response.total_hits).to eq 2
      expect(response.hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"])
    end

    it "matches products with sale_price between 4.99 and 9.13" do
      response = Product.search("*", filters: { sale_price: (4.99..9.13) })
      expect(response.total_hits).to eq 3
    end

    it "matches products with sale_price between 4.99 and 9.12" do
      response = Product.search("*", filters: { sale_price: { gte: 4.99, lt: 9.13 } })
      expect(response.total_hits).to eq 2
      expect(response.hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Book: The Good Neighbor"])
    end

    it "matches products with available_stock greater than 0" do
      response = Product.search("*", filters: { available_stock: { gt: 0 } })
      expect(response.total_hits).to eq 2
      expect(response.hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Good Neighbor", "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"])
    end

    it "matches products with available_stock less than or equals to 0" do
      response = Product.search("*", filters: { not: { available_stock: { gt: 0 } } })
      expect(response.total_hits).to eq 1
    end
  end

  context "terms filters" do
    it "matches products that name is included in array" do
      response = Product.search("*", filters: { name: %w(neighbor child) })
      expect(response.total_hits).to eq 2
      expect(response.hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Book: The Good Neighbor"])
    end
  end

  context "regexp filters" do
    it "matches all products when regex filter is .*" do
      response = Product.search("*", filters: { name: /.*/ })
      expect(response.total_hits).to eq 3
    end

    it "matches products that name matches the regexp" do
      response = Product.search("*", filters: { name: /.*(neighbor|child).* ?/ })
      expect(response.total_hits).to eq 2
      expect(response.hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Book: The Good Neighbor"])
    end
  end

  context "advanced filters" do
    it "matches the documents that satisfies the complex filtering" do
      response = Product.search("*", filters: {
                              and: {
                                active: true,
                                and: {
                                  or: [
                                    { available_stock: { gt: 300 } },
                                    { available_stock: 500 }
                                  ],
                                  sale_price: { gt: 0 }
                                }
                              }
                            })
      source = response.hits.first["_source"]
      expect(response.total_hits).to eq 1
      expect(source["name"]).to eq "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"
    end
  end
end
