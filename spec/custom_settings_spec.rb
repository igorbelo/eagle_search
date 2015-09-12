require "spec_helper"

class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search index_name: "custom_name"
end

describe "custom settings" do
  it "sets the custom index name" do
    expect(Product.index.name).to eq "custom_name"
  end

  it "sets the custom index alias name" do
    expect(Product.index.alias_name).to eq "custom_name"
  end
end
