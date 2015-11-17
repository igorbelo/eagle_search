require "spec_helper"

describe "custom filters" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false, exact_match_fields: [:name]

      def index_data
        as_json only: [:name]
      end
    end

    reindex_products
  end

  it "is expected to consider custom filters" do
    response = Product.search "*", custom_filters: {
                                bool: {
                                  should: [
                                    term: {
                                      name: "Book: The Good Neighbor"
                                    }
                                  ]
                                }
                              }

    expect(response.total_hits).to eq(1)
    expect(response.hits[0]["_source"]["name"]).to eq("Book: The Good Neighbor")
  end
end
