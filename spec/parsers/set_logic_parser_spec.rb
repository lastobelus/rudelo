require_relative '../spec_helper'

require 'rudelo/parsers/set_logic_parser'

describe "Rudelo::Parsers::SetLogicParser" do
  let(:parser) { Rudelo::Parsers::SetLogicParser.new }

  context "cardinality_expression" do
    let(:expr_parser){ parser.cardinality_expression }

    it "parses cardinality (symbols)" do
      expect(expr_parser).to    parse('#= 5', trace: true).as({
        :cardinality_expression=>{ :operator=>'#=', :qty=>"5"}
      })
      expect(expr_parser).to    parse('#> 5', trace: true).as({
        :cardinality_expression=>{ :operator=>'#>', :qty=>"5"}
      })
      expect(expr_parser).to    parse('#< 4', trace: true).as({
        :cardinality_expression=>{ :operator=>'#<', :qty=>"4"}
      })
    end

    it "parses cardinality (words)" do
      expect(expr_parser).to    parse('cardinality-equals 5', trace: true).as({
        :cardinality_expression=>{ :operator=>'cardinality-equals', :qty=>"5"}
      })
      expect(expr_parser).to    parse('cardinality-greater-than 5', trace: true).as({
        :cardinality_expression=>{ :operator=>'cardinality-greater-than', :qty=>"5"}
      })
      expect(expr_parser).to    parse('cardinality-less-than 4', trace: true).as({
        :cardinality_expression=>{ :operator=>'cardinality-less-than', :qty=>"4"}
      })
    end
  end
end