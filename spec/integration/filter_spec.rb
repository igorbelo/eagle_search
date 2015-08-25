require 'spec_helper'
require 'eagle_search'

class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search
end

Product.create_index

describe "filter" do
end
