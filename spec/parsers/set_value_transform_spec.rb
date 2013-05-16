require_relative '../spec_helper'

require 'rudelo/parsers/set_value_parser'

describe "Rudelo::Parsers::SetValueTransform" do
  let(:parser) { Rudelo::Parsers::SetValueParser.new }
  let(:xform) { Rudelo::Parsers::SetValueTransform.new }

  it "transforms an element to a string" do
    expect(xform.apply(:element => "bob")).to eq("bob")
  end

  it "transforms a set to a Set" do
    expect(xform.apply({:element_list=>[{:element=>"bob"}, {:element=>"mary"}]})).to eq(Set['mary', 'bob'])
  end

  it "works on a single element" do
    expect(xform.apply(parser.parse('bob'))).to eq(Set['bob'])
  end
end