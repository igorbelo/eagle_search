require "spec_helper"
require "pry"

describe "highlight" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false

      def index_data
        as_json only: [:name]
      end
    end

    reindex_products
  end

  it "does not highlight without fields" do
    products = Product.search "book", highlight: { tags: ["<strong>"] }
    products.hits.each do |hit|
      expect(hit["highlight"]).to be_nil
    end
  end

  it "does highlight specified fields with <em> default tag" do
    products = Product.search "book", highlight: { fields: [:name] }
    expect(products.hits.map { |hit| hit["highlight"]["name"] }).to eq(["<em>Book</em>: The Good Neighbor", "<em>Book</em>: The Hidden Child"])
  end

  it "does highlight specified fields with specified tags" do
    products = Product.search "book", highlight: { fields: [:name], tags: ["<strong>"] }
    expect(products.hits.map { |hit| hit["highlight"]["name"] }).to eq(["<strong>Book</strong>: The Good Neighbor", "<strong>Book</strong>: The Hidden Child"])
  end
end
