require "spec_helper"

describe "custom settings" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search index_name: "custom_name", mappings: {
                     custom_type: {
                       properties: {
                         name: {
                           index: "no",
                           type: "string"
                         },
                         description: {
                           index: "not_analyzed",
                           type: "string"
                         }
                       }
                     }
                   }
    end

    Product.create_index
  end

  it "is expected that custom field mappings were integrated" do
    properties = Product.index_info["custom_name"]["mappings"]["custom_type"]["properties"]
    expect(properties["name"]).to eq({ "index" => "no", "type" => "string" })
    expect(properties["description"]).to eq({ "index" => "not_analyzed", "type" => "string" })
  end
end
