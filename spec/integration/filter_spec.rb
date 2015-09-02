require "spec_helper"

describe "filtering" do
  context "with default mappings" do
    context "by name" do
      it "matches 2 documents when filter matches by name" do
        hits = Product.search("*", filters: { name: "book" }).hits
        expect(hits.size).to eq 2
      end

      it "does not match any document when filter does not match by name" do
        hits = Product.search("*", filters: { name: "i'm not in a document" }).hits
        expect(hits.size).to eq 0
      end

      it "matches only 'Book: The Good Neighbor' product when filtering by name = 'neighbor'" do
        hits = Product.search("*", filters: { name: "neighbor" }).hits
        source = hits.first["_source"]
        expect(hits.size).to eq 1
        expect(source["name"]).to eq "Book: The Good Neighbor"
      end
    end

    context "by multiple fields" do
      it "matches only 'Book: The Good Neighbor' product when filtering by name = 'neighbor' and active products" do
        hits = Product.search("*", filters: { and: { name: "neighbor", active: true } }).hits
        source = hits.first["_source"]
        expect(hits.size).to eq 1
        expect(source["name"]).to eq "Book: The Good Neighbor"
      end

      it "matches only 'Book: The Hidden Child' product when filtering by available_stock = true and inactive products" do
        hits = Product.search("*", filters: { and: { active: false } }).hits
        source = hits.first["_source"]
        expect(hits.size).to eq 1
        expect(source["name"]).to eq "Book: The Hidden Child"
      end
    end

    context "range filters" do
      it "matches products with sale_price greather or equal than 4.99" do
        hits = Product.search("*", filters: { sale_price: { gte: 4.99 } }).hits
        expect(hits.size).to eq 3
      end

      it "matches products with sale_price greather than 4.99" do
        hits = Product.search("*", filters: { sale_price: { gt: 4.99 } }).hits
        expect(hits.size).to eq 2
        expect(hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"])
      end

      it "matches products with sale_price between 4.99 and 9.13" do
        hits = Product.search("*", filters: { sale_price: (4.99..9.13) }).hits
        expect(hits.size).to eq 3
      end

      it "matches products with sale_price between 4.99 and 9.12" do
        hits = Product.search("*", filters: { sale_price: { gte: 4.99, lt: 9.13 } }).hits
        expect(hits.size).to eq 2
        expect(hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Hidden Child", "Book: The Good Neighbor"])
      end

      it "matches products with available_stock greater than 0" do
        hits = Product.search("*", filters: { available_stock: { gt: 0 } }).hits
        expect(hits.size).to eq 2
        expect(hits.map { |h| h["_source"]["name"] }).to match_array(["Book: The Good Neighbor", "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top"])
      end

      it "matches products with available_stock less than or equals to 0" do
        hits = Product.search("*", filters: { not: { available_stock: { gt: 0 } } }).hits
        expect(hits.size).to eq 1
      end
    end
  end
end
