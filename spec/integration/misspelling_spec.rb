require "spec_helper"

describe "misspelling" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false

      def index_data
        as_json only: [:name, :description, :mpn]
      end
    end

    reindex_products
  end

  it "matches when neighbor is mispelled by distance 1" do
    results = Product.search "neighbour"
    expect(results.total_hits).to eq(1)
    expect(results.hits.map { |h| h["_source"]["name"] }).to eq(["Book: The Good Neighbor"])
  end

  it "matches when neighbor is mispelled by distance 2" do
    results = Product.search "neighhbour"
    expect(results.total_hits).to eq(1)
    expect(results.hits.map { |h| h["_source"]["name"] }).to eq(["Book: The Good Neighbor"])
  end

  it "does not match when neighbor is mispelled by distance 3" do
    results = Product.search "neighhbbour"
    expect(results.total_hits).to eq(0)
  end
end
