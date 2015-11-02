require "spec_helper"

describe "custom payload" do
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

  let(:custom_payload) do
    {
      query: {
        filtered: {
          query: {
            match_all: {},
          },
          filter: {
            bool: {
              must_not: [
                {
                  term: {
                    active: false
                  }
                }
              ]
            }
          }
        }
      }
    }
  end

  it "considers the payload over any option" do
    response = Product.search "something", custom_payload: custom_payload, filters: { available_stock: 300 }
    expect(response.total_hits).to eq(2)
    response.hits.each do |hit|
      expect(hit["_source"]["active"]).to be_truthy
    end
  end
end
