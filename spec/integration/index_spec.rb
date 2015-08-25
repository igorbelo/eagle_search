require 'spec_helper'
require 'eagle_search'

class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search
end

describe "index" do
  context "default" do
    it "creates an index with defaults" do
      Product.create_index
    end
  end
end
