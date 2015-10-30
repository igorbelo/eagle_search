require "spec_helper"

describe "sort" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search

      def index_data
        as_json only: [:name, :description]
      end
    end

    reindex_products
  end

  it "sorts the hits by name" do
    response = Product.search "*", sort: { name: :desc }
    expect(response.hits.map { |hit| hit["_source"]["name"] }).to eq(["Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top", "Book: The Good Neighbor", "Book: The Hidden Child"])
  end
end
