require "spec_helper"

describe "default settings" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search

      def index_data
        as_json only: [:id, :available_stock, :created_at, :updated_at, :active, :name, :description, :sale_price, :list_price]
      end
    end

    Product.create_index
  end

  describe "properties" do
    let(:properties) do
      index = Product.eagle_search_index
      index.mappings[index.type_name][:properties]
    end

    it "sets default settings for id" do
      expect(properties["id"]).to eq({ type: "integer" })
    end

    it "sets default settings for available_stock" do
      expect(properties["available_stock"]).to eq({ type: "integer" })
    end

    it "sets default settings for created_at" do
      expect(properties["created_at"]).to eq({ type: "date" })
    end

    it "sets default settings for updated_at" do
      expect(properties["updated_at"]).to eq({ type: "date" })
    end

    it "sets default settings for active" do
      expect(properties["active"]).to eq({ type: "boolean" })
    end

    it "sets default settings for name" do
      expect(properties["name"]).to eq({ index: "analyzed", type: "string", analyzer: "english", fields: {
                                           shingle: {
                                             type: "string",
                                             analyzer: "eagle_search_shingle_analyzer"
                                           }
                                         }
                                       })
    end

    it "sets default settings for description" do
      expect(properties["description"]).to eq({ index: "analyzed", type: "string", analyzer: "english", fields: {
                                                  shingle: {
                                                    type: "string",
                                                    analyzer: "eagle_search_shingle_analyzer"
                                                  }
                                                }
                                              })
    end

    it "sets default settings for sale_price" do
      expect(properties["sale_price"]).to eq({ type: "float" })
    end

    it "sets default settings for list_price" do
      expect(properties["list_price"]).to eq({ type: "float" })
    end
  end
end
