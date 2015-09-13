require "spec_helper"

describe "custom settings" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search index_name: "custom_name", mappings: {
                     custom_type: {
                       properties: {
                         name: {
                           type: "string",
                           index: "no"
                         }
                       }
                     }
                   }
    end
    Product.create_index
  end

  after(:all) { EagleSearch.client.indices.delete index: "#{ Product.index.alias_name }*" }

  let(:index_name) { Product.index.name }
  let!(:response) { EagleSearch.client.indices.get(index: index_name) }

  it "matches the custom index name" do
    expect(response.keys).to eq %w(custom_name)
  end

  it "matches the custom alias name" do
    expect(response["custom_name"]["aliases"]).to eq({ "custom_name" => {} })
  end

  it "matches the custom mappings" do
    properties_response = response["custom_name"]["mappings"]["custom_type"]["properties"]
    expect(properties_response["name"]["type"]).to eq "string"
    expect(properties_response["name"]["index"]).to eq "no"
  end
end
