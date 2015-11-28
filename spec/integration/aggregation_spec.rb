require "spec_helper"

describe "aggregation" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false, exact_match_fields: [:name, :description, :category, :comment]

      def index_data
        as_json only: [:name, :description, :available_stock, :sale_price, :category, :comment]
      end
    end

    reindex_products
  end

  it "returns just one terms aggregation" do
    response = Product.search "*", aggregations: :category
    buckets = response.aggregations["category"]["buckets"]

    expect(buckets.first["key"]).to eq("Book")
    expect(buckets.first["doc_count"]).to eq(2)
    expect(buckets.second["key"]).to eq("Vesture")
    expect(buckets.second["doc_count"]).to eq(1)
  end

  it "returns just one stats aggregation" do
    response = Product.search "*", aggregations: { available_stock: { type: "stats" } }
    available_stock_stats = response.aggregations["available_stock"]

    expect(available_stock_stats["count"]).to eq(3)
    expect(available_stock_stats["min"]).to eq(0)
    expect(available_stock_stats["max"]).to eq(600)
    expect(available_stock_stats["sum"]).to eq(900)
    expect(available_stock_stats["avg"]).to eq(300)
  end

  it "returns separated terms and stats aggregations" do
    response = Product.search "*", aggregations: [:category, available_stock: { type: "stats" }]
    buckets = response.aggregations["category"]["buckets"]
    stats = response.aggregations["available_stock"]

    expect(buckets.first["key"]).to eq("Book")
    expect(buckets.first["doc_count"]).to eq(2)
    expect(buckets.second["key"]).to eq("Vesture")
    expect(buckets.second["doc_count"]).to eq(1)

    expect(stats["count"]).to eq(3)
    expect(stats["min"]).to eq(0)
    expect(stats["max"]).to eq(600)
    expect(stats["sum"]).to eq(900)
    expect(stats["avg"]).to eq(300)
  end

  it "returns mixed terms and stats aggregations" do
    response = Product.search "*", aggregations: { category: { available_stock: { type: "stats" } } }
    buckets = response.aggregations["category"]["buckets"]

    expect(buckets.map { |h| h["key"] }).to eq(["Book", "Vesture"])
    expect(buckets.map { |h| h["doc_count"] }).to eq([2, 1])
    expect(buckets.map { |h| h["available_stock"]["count"] }).to eq([2, 1])
    expect(buckets.map { |h| h["available_stock"]["min"] }).to eq([0, 600])
    expect(buckets.map { |h| h["available_stock"]["max"] }).to eq([300, 600])
    expect(buckets.map { |h| h["available_stock"]["avg"] }).to eq([150, 600])
    expect(buckets.map { |h| h["available_stock"]["sum"] }).to eq([300, 600])
  end

  it "returns mixed terms aggregations many levels deep" do
    response = Product.search "*", aggregations: [:comment, { category: { name: :description } }]
    comment_buckets = response.aggregations["comment"]["buckets"]
    category_buckets = response.aggregations["category"]["buckets"]
    name_buckets = category_buckets.flat_map { |h| h["name"]["buckets"] }
    description_buckets = name_buckets.flat_map { |h| h["description"]["buckets"] }

    expect(comment_buckets.first["key"]).to eq("Awesome product")
    expect(comment_buckets.first["doc_count"]).to eq(1)

    expect(category_buckets.map { |h| h["key"] }).to eq(["Book", "Vesture"])
    expect(category_buckets.map { |h| h["doc_count"] }).to eq([2, 1])

    expect(name_buckets.map { |h| h["key"] }).to eq(["Book: The Good Neighbor", "Book: The Hidden Child", "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"])
    expect(name_buckets.map { |h| h["doc_count"] }).to eq([1, 1, 1])

    expect(description_buckets.map { |h| h["key"] }).to eq(["From a phenomenal new voice in suspense fiction comes a book that will forever change the way you look at the people closest to you", "The brilliant new psychological thriller from worldwide bestseller Camilla Läckberg—the chilling struggle of a young woman facing the darkest chapter of Europe’s past.", "Simply design tunic dress which is basic but stylish."])
    expect(description_buckets.map { |h| h["doc_count"] }).to eq([1, 1, 1])
  end

  it "returns mixed terms and ranges aggregations" do
    response = Product.search "*", aggregations: { available_stock: { ranges: [{ from: 0, to: 300 }, (300..600), { from: 600 }] }, category: :name }
    category_buckets = response.aggregations["category"]["buckets"]
    available_stock_buckets = response.aggregations["available_stock"]["buckets"]

    expect(category_buckets.map { |h| h["key"] }).to eq(["Book", "Vesture"])
    expect(category_buckets.map { |h| h["doc_count"] }).to eq([2, 1])
    expect(category_buckets.flat_map { |h| h["name"]["buckets"] }.map { |h| h["key"] }).to eq(["Book: The Good Neighbor", "Book: The Hidden Child", "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"])
    expect(category_buckets.flat_map { |h| h["name"]["buckets"] }.map { |h| h["doc_count"] }).to eq([1, 1, 1])

    expect(available_stock_buckets.map { |h| h["key"] }).to eq(["0.0-300.0", "300.0-600.0", "600.0-*"])
    expect(available_stock_buckets.map { |h| h["doc_count"] }).to eq([1, 1, 1])
  end
end
