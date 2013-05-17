require_relative '../spec_helper'

require 'rudelo/parsers/set_logic_parser'
require 'rudelo/parsers/set_logic_transform'

describe "Rudelo::Parsers::SetLogicTransform" do
  let(:parser) { Rudelo::Parsers::SetLogicParser.new }
  let(:in_set){ Set.new(%w{a b c}) }
  let(:xform) { Rudelo::Parsers::SetLogicTransform.new(in_set) }

  context "ops" do
    specify{expect(xform.apply(:op => "+")).to eq(:"+")}
    specify{expect(xform.apply(:op => "#=")).to eq(:"==")}
    specify{expect(xform.apply(:op => "cardinality-equals")).to eq(:"==")}
    specify{expect(xform.apply(:op => "#>")).to eq(:>)}
    specify{expect(xform.apply(:op => "cardinality-greater-than")).to eq(:>)}
    specify{expect(xform.apply(:op => "proper-superset")).to eq(:proper_superset?)}

  end

  context "CardinalityExpr" do
    subject{ Rudelo::Parsers::SetLogicTransform::CardinalityExpr }
    let(:set){ Set.new(%w{a b c}) }
    specify{ expect(subject.new(:>, 2).eval(set)).to be_true }
    specify{ expect(subject.new(:<, 2).eval(set)).to be_false }
    specify{ expect(subject.new(:==, 2).eval(set)).to be_false }
    specify{ expect(subject.new(:==, 3).eval(set)).to be_true }
  end

  context "SetLogicExpr" do
    subject{ Rudelo::Parsers::SetLogicTransform::SetLogicExpr }
    let(:set1){ Set.new(%w{a b c}) }
    let(:set2){ Set.new(%w{b c}) }
    let(:set3){ Set.new(%w{b c d}) }
    specify{ expect(
      subject.new(set1, :proper_superset?, set2).eval
    ).to be_true }
    specify{ expect(subject.new(set1, :proper_subset?, set2).eval).to be_false }
    specify{ expect(subject.new(set3, :proper_subset?, set1).eval).to be_false }
    specify{ expect(subject.new(set1, :==, set1).eval).to be_true }
  end



  context "match expressions" do
    subject{ xform.apply(parser.parse(expr)) }
    context "cardinality expressions alone" do
      let(:set){ Set.new(%w{a b c}) }
      let(:expr){ "#> 2" }
      it "should transform cardinality_expressions as match_expression.right" do
        expect(subject[:match_expression][:right]).to be_a_kind_of(
        Rudelo::Parsers::SetLogicTransform::CardinalityExpr)
      end
      it "should set match_expression.left to in_set" do
        expect(subject[:match_expression][:left]).to be_nil
      end

      it "should eval correctly" do
        expect(subject[:match_expression][:right].eval(set)
        ).to be_true

        expect(
          xform.apply(
            parser.parse("#< 2")
          )[:match_expression][:right].eval(set)
        ).to be_false
      end
    end


    context "logic expression" do
      context "alone" do
        let(:expr){ "$(k z v) > $in" }
        it "transforms logic expression as match_expression.left" do
          expect(subject[:match_expression][:left]).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetLogicExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject[:match_expression][:right]).to be_nil
        end

      end
      context "with cardinality" do
        let(:expr){ "$(k z v) > $in #= 2" }
        it "transforms logic expression as match_expression.left" do
          expect(subject[:match_expression][:left]).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetLogicExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject[:match_expression][:right]).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::CardinalityExpr)
        end
      end
    end

    context "construction expression" do
      context "alone" do
        let(:expr){ "$(k z v) + $in" }
        it "transforms construction expression as match_expression.left" do
          expect(subject[:match_expression][:left]).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetConstructionExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject[:match_expression][:right]).to be_nil
        end

      end
      context "with cardinality" do
        let(:expr){ "$(k z v) + $in #= 2" }
        it "transforms construction expression as match_expression.left" do
          expect(subject[:match_expression][:left]).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetConstructionExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject[:match_expression][:right]).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::CardinalityExpr)
        end

      end

      it "should transform construction expressions" do
        a = '$(a b c d) > $in #> 1'
        b = '$(a b c d) > $in'
        c = '$(k z v) + $in'
        d = '$(k z v) + $in - $(a) #= 5'
        in_set = Set.new(%w{a b c})
        puts "---------- logic alone"
        # pp parser.parse(b)
        # puts
        xform.in_set = in_set
        pp xform.apply(parser.parse(b))
        puts
        puts "---------- logic with cardinality"
        # pp parser.parse(a)
        # puts
        xform.in_set = in_set
        pp xform.apply(parser.parse(a))
        puts
        puts
        puts "---------- construction alone"
        pp parser.parse(c)
        puts
        xform.in_set = in_set
        pp xform.apply(parser.parse(c))
        puts
        puts "---------- construction with cardinality"
        pp parser.parse(a)
        puts
        xform.in_set = in_set
        pp xform.apply(parser.parse(d))
        puts
        puts
      end
    end
  end
end