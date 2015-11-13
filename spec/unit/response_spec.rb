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

  describe "#records" do
    subject { EagleSearch::Response.new(Product, response, {}) }

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
end
