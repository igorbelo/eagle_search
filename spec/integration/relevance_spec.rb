require "spec_helper"

describe "relevance" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search exact_match_fields: [:mpn]

      def index_data
        as_json only: [:name, :description, :mpn]
      end
    end

    Product.all.map(&:destroy)

    Product.create(name: "Quick brown rabbits", description: "Brown P167482 rabbits P167482 are commonly seen.", mpn: "P98817")
    Product.create(name: "Keeping pets healthy", description: "My quick brown P98817 fox eats rabbits P98817 on a regular basis.", mpn: "P167482")
    Product.create(name: "the hungry alligator ate sue")
    Product.create(name: "Sue ate the alligator")
    reindex_products
  end

  it "is expected that match on both fields to rank higher" do
    response = Product.search "Quick pets"
    hits = response.hits
    expect(hits[0]["_source"]["name"]).to eq("Keeping pets healthy")
    expect(hits[1]["_source"]["name"]).to eq("Quick brown rabbits")
  end

  it "is expected that shingle fields to rank higher" do
    response = Product.search "the alligator ate sue"
    hits = response.hits
    expect(hits[0]["_source"]["name"]).to eq("the hungry alligator ate sue")
    expect(hits[1]["_source"]["name"]).to eq("Sue ate the alligator")

    response = Product.search "sue ate alligator"
    hits = response.hits
    expect(hits[0]["_source"]["name"]).to eq("Sue ate the alligator")
    expect(hits[1]["_source"]["name"]).to eq("the hungry alligator ate sue")
  end

  it "is expected that match exact fields to rank higher" do
    response = Product.search "P167482"
    hits = response.hits
    expect(hits[0]["_source"]["mpn"]).to eq("P167482")
    expect(hits[1]["_source"]["mpn"]).to eq("P98817")
  end
end
