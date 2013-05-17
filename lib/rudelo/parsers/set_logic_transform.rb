require 'rudelo/parsers/set_value_transform'

module Rudelo
  module Parsers

    class SetLogicTransform < Rudelo::Parsers::SetValueTransform
    # class SetValueTransform < Parslet::Transform
      CardinalityExpr = Struct.new(:op, :qty) {
        def eval(set)
          set.size.send op, qty
        end
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
    end
  end
end