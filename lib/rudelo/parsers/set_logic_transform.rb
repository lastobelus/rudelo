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
      }

      SetConstructionExpr = Struct.new(:left, :right) {
      }

      # class SetValueTransform < Parslet::Transform
      CardinalityExpr = Struct.new(:op, :qty) {
        def eval(set)
          set.size.send op, qty
        end
      }

      Match = Struct.new(:expr) {

      }

      rule(cardinality_expression: subtree(:expr)){
        CardinalityExpr.new(expr[:op], expr[:qty])
      }

      def self.translate_op(op)
        case op
        when '#=', 'cardinality-equals';       :"=="
        when '#<','cardinality-less-than',
          'proper-subset';                     :<
        when '#>','cardinality-greater-than',
          'proper-superset';                   :>
        when 'subset';                         :<=
        when 'superset';                       :>=
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