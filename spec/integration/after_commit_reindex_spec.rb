require "spec_helper"

describe "after commit reindex" do
  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search exact_match_fields: [:name]

      def index_data
        as_json only: [:name, :description]
      end
    end
  end

  before do
    begin
      Product.eagle_search_index.info
      Product.delete_index
    rescue
    end
  end

  it "expects that index doesn't exist" do
    expect {
      Product.eagle_search_index.info
    }.to raise_error(Elasticsearch::Transport::Transport::Errors::NotFound)
  end

  it "is expected to create the index after commit" do
    Product.create(name: "Xpto")
    Product.refresh_index
    response = Product.search "*"
    expect(response.hits.first["_source"]["name"]).to eq("Xpto")
  end
end
