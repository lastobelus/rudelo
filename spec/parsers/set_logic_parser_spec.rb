require_relative '../spec_helper'
require 'pp'

require 'rudelo/parsers/set_logic_parser'

describe "Rudelo::Parsers::SetLogicParser" do
  let(:parser) { Rudelo::Parsers::SetLogicParser.new }

  context "cardinality_expression" do
    let(:expr_parser){ parser.cardinality_expression }

    it "parses cardinality (symbols)" do
      expect(expr_parser).to    parse('#= 5', trace: true).as({
        :cardinality_expression=>{ :op=>'#=', :qty=>"5"}
      })
      expect(expr_parser).to    parse('#> 5', trace: true)
      expect(expr_parser).to    parse('#< 4', trace: true)
    end

    it "parses cardinality (words)" do
      expect(expr_parser).to    parse('cardinality-equals 5', trace: true).as({
        :cardinality_expression=>{ :op=>'cardinality-equals', :qty=>"5"}
      })
      expect(expr_parser).to    parse('cardinality-greater-than 5', trace: true)
      expect(expr_parser).to    parse('cardinality-less-than 4', trace: true)
    end
  end

  context "set construction expression" do
    let(:expr_parser){ parser.set_construction_expression }

    it "parses set construction to an iterative operation list" do

      expect(expr_parser).to    parse('$(bob, mary) union $(ralph, jeff) & $in', trace: true).as({
        :set_construction_expression=>{
          :left=>{:element_list=>[{:element=>"bob"}, {:element=>"mary"}] },
          :right=>[
            { set_op: {
              left: {op: "union"},
              right: {element_list:[
                {:element=>"ralph"}, {:element=>"jeff"}
                ]}
              }},
            { set_op: {
            left: {op: "&"},
            right: {:in_set=>"$in"}}}
          ]
        }
      })
    end
    it "parses set construction ops in symbol form" do
      expect(expr_parser).to    parse('$(bob mary) & $in', trace: true)
      expect(expr_parser).to    parse('$(bob mary) + $in', trace: true)
      expect(expr_parser).to    parse('$(bob mary)-$in', trace: true)
      expect(expr_parser).to    parse('$(bob mary) ^ $in', trace: true)
    end

    it "parses set construction ops in word form" do
      expect(expr_parser).to    parse('$in intersection $(bob mary)', trace: true)
      expect(expr_parser).to    parse('$in union $(bob mary)', trace: true)
      expect(expr_parser).to    parse('$in difference $(bob mary)', trace: true)
      expect(expr_parser).to    parse('$in exclusive $(bob mary)', trace: true)
    end

  end

  context "set logic expression" do
    let(:expr_parser){ parser.set_logic_expression }

    it "parses set logic to a left-right tree" do
      expect(expr_parser).to    parse('$(bob, mary) < $(ralph, jeff, bob, mary)', trace: true).as({
        :set_logic_expression=>{
          :left=>{:element_list=>[
            {:element=>"bob"}, {:element=>"mary"}] },
          :op => "<",
          :right=>{:element_list=>[
            {:element=>"ralph"}, {:element=>"jeff"}, {:element=>"bob"}, {:element=>"mary"}]}
        }
      })
    end

    it "parses the left hand side as a set construction expression" do
      expect(expr_parser).to    parse('$(bob, mary) union $in < $(ralph, jeff, bob, mary)', trace: true).as({
        :set_logic_expression=>{
          :left=> {
            :set_construction_expression=>{
              :left=>{
                :element_list=>[{:element=>"bob"}, {:element=>"mary"}]
              },
              :right=>[{set_op: { left: {:op=>"union"}, right: {:in_set=>"$in"}}}]
            }
          },
          :op => "<",
          :right=>{:element_list=>[
            {:element=>"ralph"}, {:element=>"jeff"}, {:element=>"bob"}, {:element=>"mary"}]}
        }
      })
    end

    it "parses set logic ops in symbol form" do
      expect(expr_parser).to    parse('$(bob, mary) < $in', trace: true)
      expect(expr_parser).to    parse('$(bob, mary) <= $in', trace: true)
      expect(expr_parser).to    parse('$(bob, mary)>$in', trace: true)
      expect(expr_parser).to    parse('$(bob, mary) >= $in', trace: true)
    end

    it "parses set logic ops in word form" do
      expect(expr_parser).to    parse('$in superset $(bob, mary)', trace: true)
      expect(expr_parser).to    parse('$in subset $(bob, mary)', trace: true)
      expect(expr_parser).to    parse('$in proper-superset $(bob, mary)', trace: true)
      expect(expr_parser).to    parse('$in proper-subset $(bob, mary)', trace: true)
    end

  end

  context "set logic expression" do
    let(:expr_parser){ parser.match_expression }
    it "parses a bare cardinality expression" do
      expect(expr_parser).to    parse('#= 5', trace: true).as({
        match_expression: {
          right: {
            cardinality_expression: {op: "#=", qty: "5"}
          }
        }
      })
    end

    it "parses an explicit set expression" do
      expect(expr_parser).to    parse('$(bob, jeff)', trace: true).as({
        superset_match_expression: {
          element_list: [{element: "bob"}, {element: "jeff"}]
        }
      })
    end

    it "parses a set construction expression with optional cardinality" do
      expect(expr_parser).to    parse('$(bob, jeff) + $in', trace: true)
      expect(expr_parser).to    parse('$(bob, jeff) + $in #> 3', trace: true)
    end

    it "parses a set logic expression with optional cardinality" do
      expect(expr_parser).to    parse('$(bob, jeff) <= $in', trace: true)
      expect(expr_parser).to    parse('$(bob, jeff) <= $in #> 3', trace: true)
    end

  end
end
