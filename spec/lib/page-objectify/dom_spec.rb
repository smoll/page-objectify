require "page-object"
require "page-objectify/dom"
require "page-objectify/logging"
require "spec_helper"

RSpec.describe PageObjectify::DOM do
  subject { described_class.new(html) }
  let(:html) { '<html></html>' }

  # For these 2 tests, see `puts` from: #to_accessors -> script tag -> does not attempt to generate an accessor for it

  describe "#tags_to_accessors" do
    # Compare against PageObject's list of instance methods
    it "doesn't contain any invalid mappings" do
      subject.tags_to_accessors.each do |k, v|
        expect(PageObject::LocatorGenerator::ADVANCED_ELEMENTS).to include(v.to_sym)
      end
    end
  end

  describe "#input_types_to_accessors" do
    # Compare against PageObject's list of instance methods
    it "doesn't contain any invalid mappings" do
      subject.input_types_to_accessors.each do |k, v|
        expect(PageObject::LocatorGenerator::ADVANCED_ELEMENTS).to include(v.to_sym)
      end
    end
  end

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

        # echo logger output of tag -> accessor method mapping, for debugging purposes
        puts captured.string
      end
    end
  end
end
