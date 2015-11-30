require "spec_helper"

shared_examples "searching matches" do
  it "does not match when searching by a non-existent term" do
    results = Product.search "jaoijgioahr"
    expect(results.total_hits).to eq(0)
  end

  it "matches when searching by part of sentence" do
    results = Product.search "neighbor"
    expect(results.total_hits).to eq(1)
    expect(results.hits.map { |h| h["_source"]["name"] }).to eq(["Book: The Good Neighbor"])
  end
end

describe "search" do
  context "without exact match fields" do
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

    after(:all) { Product.all.map(&:destroy) }

    include_examples "searching matches"
  end

  context "without exact match fields" do
    before(:all) do
      class Product < ActiveRecord::Base
        include EagleSearch
        eagle_search reindex: false, exact_match_fields: [:mpn]

        def index_data
          as_json only: [:name, :description, :mpn]
        end
      end

      reindex_products
    end

    after(:all) { Product.all.map(&:destroy) }

    include_examples "searching matches"
  end
end
