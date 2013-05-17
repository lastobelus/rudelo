require 'rudelo/parsers/set_value_transform'

module Rudelo
  module Parsers


    class SetLogicTransform < Rudelo::Parsers::SetValueTransform


      attr_accessor :in_set, :set_value
      def initialize(in_set=::Set.new, &block)
        @in_set = in_set
        @set_value = SetValueTransform.new
        super()
      end

      def apply(obj, context=nil)
        super @set_value.apply(obj, context), {in_set: @in_set}
      end

      SetLogicExpr = Struct.new(:left, :op, :right) {
        def eval
          left.send(op, right)
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

      SetOp = Struct.new(:op, :arg) {
        def eval(set)
          set.send(op, arg)
        end
      }

      # class SetValueTransform < Parslet::Transform
      CardinalityExpr = Struct.new(:op, :qty) {
        def eval(set)
          set.size.send(op, qty)
        end
      }

      MatchExpr = Struct.new(:left, :right) {

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


    end
  end
end