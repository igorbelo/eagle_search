require "spec_helper"

describe "pagination" do
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

  it "paginates the returned hits if per_page is lower than total hits" do
    results = Product.search "*", page: 2, per_page: 2

    expect(results.total_hits).to eq(3)
    expect(results.hits.size).to eq(1)
    expect(results.hits.first["_source"]["name"]).to eq("Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top")
  end

  it "returns all hits in one page if per_page is greater than or equal to total hits" do
    results = Product.search "*", page: 1, per_page: 3

    expect(results.total_hits).to eq(3)
    expect(results.hits.size).to eq(3)
  end
end
