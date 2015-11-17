require "spec_helper"

describe EagleSearch::Response do
  let(:response) do
    {
      "hits" => {
        "hits" => [
          {
            "_id" => 1
          },
          {
            "_id" => 3
          },
          {
            "_id" => 234
          },
          {
            "_id" => 97
          }
        ]
      }
    }
  end

  before(:all) do
    class Product < ActiveRecord::Base
      include EagleSearch
      eagle_search reindex: false

      def index_data
        as_json only: [:name, :description]
      end
    end
  end

  subject { EagleSearch::Response.new(Product, response, {}) }

  describe "#records" do
    context "when another ActiveRecord model is included" do
      subject { EagleSearch::Response.new(Product, response, includes: :xpto) }

      it "calls .includes method with included model" do
        allow(Product).to receive(:includes).and_return(Product)
        expect(Product).to receive(:includes).with(:xpto).once
        subject.records
      end
    end

    context "when no other model is included" do
      it "does not call .includes method" do
        expect(Product).to_not receive(:includes).with(:xpto)
        subject.records
      end
    end

    it "calls where with returned _ids" do
      product_records = double("ProductRecords")

      allow(Product).to receive(:where).and_return(product_records)
      expect(Product).to receive(:where).with(Product.primary_key => [1, 3, 234, 97]).once

      expect(subject.records).to eq(product_records)
    end
  end

  describe "#each" do
    let(:records) { Product.all }
    before do
      Product.create(name: "Xpto")
      allow(subject).to receive(:records).and_return(records)
    end

    it "returns an enumerator if no block given" do
      enumerator = double("Enumerator")
      allow(records).to receive(:to_enum).and_return(enumerator)
      expect(subject.each).to eq(enumerator)
    end

    it "yields article if block given" do
      subject.each do |product|
        expect(product.name).to eq("Xpto")
        expect(product).to be_an(Product)
      end
    end
  end
end
