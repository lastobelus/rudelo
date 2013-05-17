require_relative '../spec_helper'

require 'rudelo/parsers/set_logic_parser'
require 'rudelo/parsers/set_logic_transform'

describe "Rudelo::Parsers::SetLogicTransform" do
  let(:parser) { Rudelo::Parsers::SetLogicParser.new }
  let(:xform) { Rudelo::Parsers::SetLogicTransform.new }

  context "ops" do
    specify{expect(xform.apply(:op => "+")).to eq(:"+")}
    specify{expect(xform.apply(:op => "#=")).to eq(:"==")}
    specify{expect(xform.apply(:op => "cardinality-equals")).to eq(:"==")}
    specify{expect(xform.apply(:op => "#>")).to eq(:>)}
    specify{expect(xform.apply(:op => "cardinality-greater-than")).to eq(:>)}
    specify{expect(xform.apply(:op => "proper-superset")).to eq(:>)}

  end

  context "CardinalityExpr" do
    subject{ Rudelo::Parsers::SetLogicTransform::CardinalityExpr }
    let(:set){ Set.new(%w{a b c}) }
    specify{ expect(subject.new(:>, 2).eval(set)).to be_true }
    specify{ expect(subject.new(:<, 2).eval(set)).to be_false }
    specify{ expect(subject.new(:==, 2).eval(set)).to be_false }
    specify{ expect(subject.new(:==, 3).eval(set)).to be_true }

    it "should transform cardinality_expressions" do
      puts
      pp parser.parse("#> 2") 
      puts
      pp xform.apply( parser.parse("#> 2") )
      puts
      expect(
        xform.apply( 
          parser.parse("#> 2") 
        )[:match_expression][:right]).to be_a_kind_of(
      Rudelo::Parsers::SetLogicTransform::CardinalityExpr)

      expect(
        xform.apply( 
          parser.parse("#> 2") 
        )[:match_expression][:right].eval(set)
      ).to be_true

      expect(
        xform.apply(
          parser.parse("#< 2")
        )[:match_expression][:right].eval(set)
      ).to be_false
    end
  end


  context "construction expression" do
    it "should transform construction expressions" do
      s = '$(a b c d) > $in #> 1'
      t = '$(a b c d) > $in'
      in_set = Set.new(%w{a b})
      puts
      pp parser.parse(s)
      puts
      xform.in_set = in_set
      pp xform.apply(parser.parse(s))
      puts
      puts
      pp parser.parse(t)
      puts
      xform.in_set = in_set
      pp xform.apply(parser.parse(t))
      puts
    end

  end

end