require "page-object"
require "page-objectify/dom_to_ruby"
require "spec_helper"

RSpec.describe PageObjectify::DOMToRuby do
  subject { described_class.new(dom, config) }
  let(:dom) { PageObjectify::DOM.new('<a href="abc.html" id="myid">something</a>') }
  let(:config) { PageObjectify::Config.new(generator_class: "StubbedPageGenerator") }

  describe "#unparse" do
    context "page with 1 element" do
      it "returns the expected Ruby source as a String" do
        expected_source = <<-RUBY.gsub(/^\s*\|/, '')
                          |class StubbedPage < BasePage
                          |  link(:myid, id: "myid")
                          |end
                          RUBY
        expect(subject.unparse).to eq(expected_source.chomp)
      end
    end

    context "page with 3 elements" do
      let(:dom) { PageObjectify::DOM.new(html) }
      let(:html) do
        '<a href="1.html" id="c">something</a>'\
        '<a href="2.html" id="b">something</a>'\
        '<a href="3.html" id="a">something</a>'
      end

      it "lists all 3 accessors, sorted lexicographically on method name" do
        expected_source = <<-RUBY.gsub(/^\s*\|/, '')
                          |class StubbedPage < BasePage
                          |  link(:a, id: "a")
                          |  link(:b, id: "b")
                          |  link(:c, id: "c")
                          |end
                          RUBY
        expect(subject.unparse).to eq(expected_source.chomp)
      end
    end
  end
end
