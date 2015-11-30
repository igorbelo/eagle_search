require "spec_helper"

shared_examples "synonyms searching" do
  it "matches documents that has 'child' searching by 'kid'" do
    response = Product.search "kid"
    expect(response.hits.map { |h| h["_source"]["name"] }).to eq(["Book: The Hidden Child"])
  end

  it "matches documents that has 'hidden' searching by 'missing'" do
    response = Product.search "missing"
    expect(response.hits.map { |h| h["_source"]["name"] }).to eq(["Book: The Hidden Child"])
  end

  it "matches documents that has 'book' searching by 'title'" do
    response = Product.search "title"
    expect(response.hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Book: The Good Neighbor"])
  end
end

describe "synonyms" do
  context "without synonyms" do
    before(:all) do
      class Product < ActiveRecord::Base
        include EagleSearch
        eagle_search reindex: false, exact_match_fields: [:mpn]

        def index_data
          as_json only: [:name, :description, :mpn]
        end
      end

      reindex_products
    end

    after(:all) { Product.all.map(&:destroy) }

    it "does not match documents that has 'child' searching by 'kid'" do
      response = Product.search "kid"
      expect(response.total_hits).to eq(0)
    end

    it "does not match documents that has 'hidden' searching by 'missing'" do
      response = Product.search "missing"
      expect(response.total_hits).to eq(0)
    end

    it "does not match documents that has 'book' searching by 'title'" do
      response = Product.search "title"
      expect(response.total_hits).to eq(0)
    end
  end

  context "when synonyms are declared on options" do
    before(:all) do
      class Product < ActiveRecord::Base
        include EagleSearch
        eagle_search reindex: false, exact_match_fields: [:mpn], synonyms: [
                       "child, kid",
                       "hidden, missing",
                       "book, title"
                     ]

        def index_data
          as_json only: [:name, :description, :mpn]
        end
      end

      reindex_products
    end

    after(:all) { Product.all.map(&:destroy) }

    include_examples "synonyms searching"
  end

  context "when using wordnet format" do
    before(:all) do
      class Product < ActiveRecord::Base
        include EagleSearch
        eagle_search reindex: false, exact_match_fields: [:mpn], synonyms: {
                       format: "wordnet",
                       synonyms_path: "#{ File.expand_path(File.dirname(__FILE__)) }/../support/wordnet_file.txt"
                     }

        def index_data
          as_json only: [:name, :description, :mpn]
        end
      end

      reindex_products
    end

    after(:all) { Product.all.map(&:destroy) }

    include_examples "synonyms searching"
  end

  context "when using solr format" do
    before(:all) do
      class Product < ActiveRecord::Base
        include EagleSearch
        eagle_search reindex: false, exact_match_fields: [:mpn], synonyms: {
                       format: "solr",
                       synonyms_path: "#{ File.expand_path(File.dirname(__FILE__)) }/../support/solr_file.txt"
                     }

        def index_data
          as_json only: [:name, :description, :mpn]
        end
      end

      reindex_products
    end

    after(:all) { Product.all.map(&:destroy) }

    include_examples "synonyms searching"
  end
end
