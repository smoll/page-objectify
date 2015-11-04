require "page-object/generator/version"
require "spec_helper"

RSpec.describe "version" do
  it "is a valid semantic version" do
    expect(PageObject::Generator::VERSION).to match(/^\d+\.\d+\.?\d*$/)
  end
end
