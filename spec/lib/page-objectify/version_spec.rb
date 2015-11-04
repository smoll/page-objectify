require "page-objectify/version"
require "spec_helper"

RSpec.describe "version" do
  it "is a valid semantic version" do
    expect(PageObjectify::VERSION).to match(/^\d+\.\d+\.?\d*$/)
  end
end
