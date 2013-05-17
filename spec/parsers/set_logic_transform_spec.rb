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
        )[:cardinality_match]).to be_a_kind_of(
      Rudelo::Parsers::SetLogicTransform::CardinalityExpr)

      expect(
        xform.apply( 
          parser.parse("#> 2") 
        )[:cardinality_match].eval(set)
      ).to be_true

      expect(
        xform.apply(
          parser.parse("#< 2")
        )[:cardinality_match].eval(set)
      ).to be_false
    end
  end



end