require "page-objectify/dom"
require "page-objectify/logging"
require "spec_helper"

RSpec.describe PageObjectify::DOM do
  subject { described_class.new(html) }
  describe "#to_accessors" do
    context "h1 tag" do
      let(:html) { '<h1 id="myid">something</h1>' }

      it "returns an Array with the correct accessor" do
        expect(subject.to_accessors).to eq [{:accessor=>"h1", :id=>"myid"}]
      end
    end

    context "a tag" do
      let(:html) { '<a href="abc.html" id="myid">something</a>' }

      it "returns an Array with the correct accessor" do
        expect(subject.to_accessors).to eq [{:accessor=>"link", :id=>"myid"}]
      end
    end

    context "script tag" do
      let(:html) { '<script id="something">var test</script>' }

      # Regression test for https://github.com/smoll/page-objectify/issues/2
      it "does not attempt to generate an accessor for it" do
        captured = StringIO.new
        PageObjectify::Logging.logger = Logger.new(captured)

        expect(subject.to_accessors).to eq []
        expect(captured.string).to_not include "Tag script is not supported!"
      end
    end
  end
end
