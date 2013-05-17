require 'rudelo/parsers/set_value_transform'

module Rudelo
  module Parsers

    class SetLogicTransform < Rudelo::Parsers::SetValueTransform
      CardinalityExpr = Struct.new(:op, :qty) {
        def eval(set)
          set.size.send op, qty
        end
      }
      rule(:element => simple(:element)) { element.to_s }
      rule(op: simple(:op)){
        case op
        when '=', 'cardinality-equals';                    :"=="
        when 'cardinality-less-than', 'proper-subset';     :<
        when 'cardinality-greater-than', 'proper-superset';:>
        when 'subset';                                     :<=
        when 'superset';                                   :>=
        when 'intersection';                               :&
        when 'union';                                      :+
        when 'difference';                                 :-
        when 'exclusive';                                  :'^'
        else
          op.to_sym
        end
      }
    end
  end
end