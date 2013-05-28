require_relative '../spec_helper'

require 'rudelo/parsers/set_logic_parser'
require 'rudelo/parsers/set_logic_transform'

describe "Rudelo::Parsers::SetLogicTransform" do
  let(:parser) { Rudelo::Parsers::SetLogicParser.new }
  let(:in_set){ Set.new(%w{a b c}) }
  let(:xform) { Rudelo::Parsers::SetLogicTransform.new(in_set) }
  let(:empty_set) { Set.new }

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

  context "SetOp" do
    subject{ Rudelo::Parsers::SetLogicTransform::SetOp }
    let(:set1){ Set.new(%w{a b c}) }
    let(:set2){ Set.new(%w{b c}) }
    let(:set3){ Set.new(%w{b c d}) }
    let(:set4){ Set.new(%w{a b c d}) }
    let(:set5){ Set.new(%w{a}) }
    specify{ expect(
      subject.new(:+, set1).eval(set3)
    ).to eq(set4) }
    specify{ expect(
      subject.new(:-, set3).eval(set4)
    ).to eq(set5) }
    specify{ expect(
      subject.new(:-, set4).eval(set3)
    ).to eq(empty_set) }
  end

  context "SetOp" do
    subject{ Rudelo::Parsers::SetLogicTransform::EmptyExpr.new }
    specify{ expect(subject.eval).to be_true }
    specify{ expect(subject.eval(false)).to be_true }
  end

  context "Set#eval" do
    let(:set1){ Set.new(%w{a b c}) }
    specify{ expect(empty_set.eval).to eq(empty_set) }
    specify{ expect(set1.eval).to eq(set1) }
  end

  context "MatchExpr" do
    subject{ Rudelo::Parsers::SetLogicTransform::MatchExpr }
    before do
      @scon_full = mock('SetConstructionExpr')
      @scon_full.stub(:eval).and_return(Set.new['a'])
      @scon_empty = mock('SetConstructionExpr')
      @scon_empty.stub(:eval).and_return(Set.new)

      @slog_true = mock('SetLogicExpr')
      @slog_true.stub(:eval).and_return(true)
      @slog_true.stub(:set).and_return(Set.new['a'])

      @slog_false = mock('SetLogicExpr')
      @slog_false.stub(:eval).and_return(false)
      @slog_false.stub(:set).and_return(Set.new)

      @scar_one = CardinalityExpr.new(:==, 1)
      @scar_two = CardinalityExpr.new(:==, 2)
    end

    context "when right is empty" do
      context "when left is SetConstructionExpr" do
        it "returns true if the result size is > 0"
        it "returns false if the result size is < 1"
      end
      context "when left is SetLogicExpr" do
        it "returns true if the result is true"
        it "returns true if the result is false"
      end
    end
    context "when right is CardinalityExpr" do
      context "when left is SetConstructionExpr" do
        it "runs cardinality expression on left result"
      end
      context "when left is SetLogicExpr" do
        it "runs cardinality expression on left set"
      end
    end

  end

  context "match expressions" do
    subject{ xform.apply(parser.parse(expr)) }
    context "cardinality expressions alone" do
      let(:set){ Set.new(%w{a b c}) }
      let(:expr){ "#> 2" }
      it "should transform cardinality_expressions as match_expression.right" do
        expect(subject.right).to be_a_kind_of(
        Rudelo::Parsers::SetLogicTransform::CardinalityExpr)
      end
      it "should set match_expression.left to in_set" do
        expect(subject.left).to eq(in_set)
      end

      it "should eval correctly" do
        expect(subject.right.eval(set)
        ).to be_true
        expect(subject.eval).to be_true

        expect(
          xform.apply(
            parser.parse("#< 2")
          ).right.eval(set)
        ).to be_false
      end
    end

    context "logic expression" do
      context "alone" do
        let(:expr){ "$(k z v) > $in" }
        it "transforms logic expression as match_expression.left" do
          expect(subject.left).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetLogicExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject.right).to be_a_kind_of(
            Rudelo::Parsers::SetLogicTransform::EmptyExpr)
        end

      end
      context "with cardinality" do
        let(:expr){ "$(k, z, v) > $in #= 2" }
        it "transforms logic expression as match_expression.left" do
          expect(subject.left).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetLogicExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject.right).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::CardinalityExpr)
        end
      end
    end

    context "construction expression" do
      context "alone" do
        let(:expr){ "$(k, z, v) + $in" }
        it "transforms construction expression as match_expression.left" do
          expect(subject.left).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetConstructionExpr)
        end
        it "should set match_expression.right to nil expr" do
          expect(subject.right).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::EmptyExpr)
        end

      end
      context "with cardinality" do
        let(:expr){ "$(k, z, v) + $in #= 2" }
        it "transforms construction expression as match_expression.left" do
          expect(subject.left).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::SetConstructionExpr)
        end
        it "should set match_expression.right to nil" do
          expect(subject.right).to be_a_kind_of(
          Rudelo::Parsers::SetLogicTransform::CardinalityExpr)
        end

      end
    end
  end

  def matching(expr, opts)
    in_set = Set.new(opts[:in_set])
    Rudelo::Parsers::SetLogicTransform.new(in_set).apply(
      Rudelo::Parsers::SetLogicParser.new.parse(expr)
    ).eval
  end

  context "cardinality examples" do
    specify{ expect(matching(
     '#= 2', in_set: %w{a, b})).to be_true }
    specify{ expect(matching(
     '#< 3', in_set: %w{a, b})).to be_true }
    specify{ expect(matching(
     '#> 1', in_set: %w{a, b})).to be_true }
    specify{ expect(matching(
     '#= 3', in_set: %w{a b})).to be_false }
    specify{ expect(matching(
     '#> 3', in_set: %w{a b})).to be_false }
    specify{ expect(matching(
     '#< 1', in_set: %w{a b})).to be_false }
  end

  context "construction examples" do
    specify{ expect(matching(
     '$(a, b, c) & $in #= 2', in_set: %w{a b d})).to be_true }
    specify{ expect(matching(
     '$(a, b, c) & $in', in_set: %w{a b d})).to be_true }
    specify{ expect(matching(
     '$(a, b, c) & $in', in_set: %w{d e f})).to be_false }
    specify{ expect(matching(
     '$(a, b, c) & $in #= 2', in_set: %w{a k d})).to be_false }
    specify{ expect(matching(
     '$(a, b, c) + $in + $(e) #= 5', in_set: %w{b c d})).to be_true }
  end

  context "explicit set examples" do
    specify{ expect(matching(
     '$(a, b, c)', in_set: %w{a b})).to be_true }
    specify{ expect(matching(
     '$(a, b, c)', in_set: %w{a k d})).to be_false }
  end

  context "logic examples" do
    specify{ expect(matching(
     '$(a, b, c) > $in', in_set: %w{a b})).to be_true }
    specify{ expect(matching(
     '$(a, b, c) > $in #=2', in_set: %w{a b})).to be_true }
    specify{ expect(matching(
     '$(a, b, c) > $in #=1', in_set: %w{a})).to be_true }
    specify{ expect(matching(
     '$(a, b, c) ^ $in < $(a, d, k, f)', in_set: %w{b c d})).to be_true }
    specify{ expect(matching(
     '$(a, b, c) ^ $in < $(a, e, k, f)', in_set: %w{b c d})).to be_false }
  end

  context "using transform with multiple in-set values" do
    it "allows re-using a transform" do
      abc = Set.new(%w{a b c})
      efg = Set.new(%w{e f g})
      expr = '$in same-as $(a, b, c)'

      transform = Rudelo::Parsers::SetLogicTransform.new(abc)
      ast = transform.apply(parser.parse(expr))

      expect(ast.eval).to be_true

      expect(ast.eval(efg)).to be_false

      expect(ast.eval(abc)).to be_true
    end

  end

end

