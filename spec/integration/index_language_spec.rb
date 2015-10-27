require "spec_helper"

describe "default settings" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search language: "portuguese"

      def index_data
        as_json only: [:name, :description]
      end
    end

    Product.create_index
  end

  describe "properties" do
    let(:properties) do
      index = Product.eagle_search_index
      index.mappings[index.type_name][:properties]
    end

    it "sets portuguese analyzer for name" do
      expect(properties["name"]).to eq({
                                         index: "analyzed", type: "string", analyzer: "portuguese", fields: {
                                           shingle: {
                                             type: "string",
                                             analyzer: "eagle_search_shingle_analyzer"
                                           }
                                         }
                                       }
                                      )
    end

    it "sets portuguese analyzer for description" do
      expect(properties["description"]).to eq({
                                                index: "analyzed", type: "string", analyzer: "portuguese", fields: {
                                                  shingle: {
                                                    type: "string",
                                                    analyzer: "eagle_search_shingle_analyzer"
                                                  }
                                                }
                                              }
                                             )
    end
  end
end
