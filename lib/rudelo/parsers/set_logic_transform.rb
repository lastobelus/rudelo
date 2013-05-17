require 'rudelo/parsers/set_value_transform'

class Set
  def eval
    self
  end
end

module Rudelo
  module Parsers


    class SetLogicTransform < Rudelo::Parsers::SetValueTransform


      attr_accessor :in_set, :set_value
      def initialize(in_set=::Set.new, &block)
        @in_set = in_set.dup # the dup is vital because we are going to be pointery later
        @set_value = SetValueTransform.new
        super()
      end

      def apply(obj, context=nil)
        super @set_value.apply(obj, context), {in_set: @in_set}
      end

      SetLogicExpr = Struct.new(:left, :op, :right) {
        def eval
          left.eval.send(op, right)
        end
        def set
          right
        end
      }

      SetConstructionExpr = Struct.new(:left, :right) {
        def eval
          right.reduce(left){|left, set_op| set_op.eval(left) }
        end
      }

      SetOp = Struct.new(:op, :right) {
        def eval(set)
          set.send(op, right)
        end
      }

      CardinalityExpr = Struct.new(:op, :qty) {
        def eval(set)
          set.size.send(op, qty)
        end
        def empty?
          false
        end
      }

      class EmptyExpr
        def eval(arg=nil)
          true
        end
        def empty?
          true
        end
      end

      MatchExpr = Struct.new(:left, :right, :in_set) {
        def eval(in_set_override=nil)
          # I've always wondered what these replace methods were for
          # and now I know. To make references more pointery.
          # The purpose of this is so we can construct a transform
          # once and use it with different values for in_set.
          in_set.replace(in_set_override) unless in_set_override.nil?
          lvalue = left.eval
          case lvalue
          when ::Set
            right.empty? ? (lvalue.size > 0) : right.eval(lvalue)
          when ::TrueClass, ::FalseClass
            lvalue && right.eval(left.set)
          else
            nil
          end
        end
      }

      rule(cardinality_expression: subtree(:expr)){
        CardinalityExpr.new(expr[:op], expr[:qty])
      }

      def self.translate_op(op)
        case op
        when '#=', 'cardinality-equals',
          'same-as', '=';                      :"=="
        when '#<','cardinality-less-than';     :<
        when '<','proper-subset';              :proper_subset?
        when '#>','cardinality-greater-than';  :>
        when '>', 'proper-superset';           :proper_superset?
        when '<=', 'subset';                   :subset?
        when '>=', 'superset';                 :superset?
        when 'intersection';                   :&
        when 'union';                          :+
        when 'difference';                     :-
        when 'exclusive';                      :'^'
        else
          op.to_sym
        end
      end

      rule(op: simple(:op)){
        SetLogicTransform.translate_op(op)
      }

      rule(qty: simple(:qty)){ qty.to_i }

      rule(op: simple(:op), qty: simple(:qty)){ 
        {op: SetLogicTransform.translate_op(op), qty: qty.to_i}
      }

      rule(in_set: simple(:x)){ in_set }

      rule(set_logic_expression: subtree(:expr)){
        SetLogicExpr.new(
          expr[:left], 
          SetLogicTransform.translate_op(expr[:op]),
          expr[:right]
        )
      }

      rule(set_construction_expression: subtree(:expr)){
        SetConstructionExpr.new(
          expr[:left], 
          expr[:right]
        )
      }

      rule(set_op: subtree(:expr)){
        SetOp.new(
          expr[:left], 
          expr[:right]
        )
      }

      rule(match_expression: subtree(:expr)){
        MatchExpr.new(
          expr[:left] || in_set, 
          expr[:right] || EmptyExpr.new,
          in_set
        )
      }

      rule(superset_match_expression: simple(:set)){
        MatchExpr.new(
          SetLogicExpr.new(in_set, :subset?, set),
          EmptyExpr.new,
          in_set
        )
      }

    end
  end
end