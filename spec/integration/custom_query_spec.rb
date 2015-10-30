require "spec_helper"

describe "custom query" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search

      def index_data
        as_json only: [:name, :description, :active, :available_stock]
      end
    end

    reindex_products
  end

  let(:custom_query) do
    {
      bool: {
        should: [
          {
            match: {
              name: {
                query: "Book: The Good Neighbor",
                minimum_should_match: "70%"
              }
            }
          }
        ]
      }
    }
  end

  it "considers the custom query over search term" do
    response = Product.search "*", custom_query: custom_query
    expect(response.total_hits).to eq(1)
    expect(response.hits[0]["_source"]["name"]).to eq("Book: The Good Neighbor")
  end

  it "merges custom query with filters" do
    response = Product.search "*", custom_query: custom_query, filters: { available_stock: { gt: 300 } }
    expect(response.total_hits).to eq(0)
  end

  it "merges custom query with custom filters" do
    response = Product.search "*", custom_query: custom_query, custom_filters: {
                                bool: {
                                  must: [
                                    {
                                      term: {
                                        active: false
                                      }
                                    }
                                  ]
                                }
                              }
    expect(response.total_hits).to eq(0)
  end
end
