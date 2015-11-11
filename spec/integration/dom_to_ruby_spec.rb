require "page-object"
require "page-objectify/dom_to_ruby"
require "spec_helper"

RSpec.describe PageObjectify::DOMToRuby do
  subject { described_class.new(dom, config) }
  let(:dom) { PageObjectify::DOM.new('<a href="abc.html" id="myid">something</a>') }
  let(:config) { PageObjectify::Config.new(generator_class: "StubbedPageGenerator") }

  describe "#unparse" do
    it "returns the expected Ruby source as a String" do
      expected_source = <<-RUBY.gsub(/^\s*\|/, '')
                        |class StubbedPage < BasePage
                        |  link(:myid, id: "myid")
                        |end
                        RUBY
      expect(subject.unparse).to eq(expected_source.chomp)
    end
  end
end
