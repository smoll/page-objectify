require "page-objectify/dom"
require "spec_helper"

RSpec.describe PageObjectify::DOM do
  subject { described_class.new(html) }
  describe "#to_accessors" do
    context "h1" do
      let(:html) { '<h1 id="myid">something</h1>' }

      it "returns an Array with the correct accessor" do
        expect(subject.to_accessors).to eq [{:accessor=>"h1", :id=>"myid"}]
      end
    end

    context "a" do
      let(:html) { '<a href="abc.html" id="myid">something</a>' }

      it "returns an Array with the correct accessor" do
        expect(subject.to_accessors).to eq [{:accessor=>"link", :id=>"myid"}]
      end
    end
  end
end
