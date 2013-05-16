require 'parslet' 
require 'rudelo/parsers/set_value_parser'

module Rudelo
  module Parsers

    module Atom
      include Parslet
      rule(:digit)   { match("[0-9]") }

      rule(:integer) do
        str("-").maybe >> match("[1-9]") >> digit.repeat
      end
    end

    class SetLogicParser < Parslet::Parser
      include Space
      include Set
      include Atom

      rule(:in_set)                       { str("$in").as(:in_set)}
      rule(:set )                           { explicit_set  |  in_set  }

      rule(:cardinality_expression) {(
          cardinality_operator.as(:operator) >> 
          space? >> 
          integer.as(:qty)
        ).as(:cardinality_expression)
      }

      rule(:cardinality_operator) {
        cardinality_eq | cardinality_gt | cardinality_lt
      }

      rule(:cardinality_eq) { str('#=')  |  str('cardinality-equals') }
      rule(:cardinality_gt) { str('#>')  |  str('cardinality-greater-than') }
      rule(:cardinality_lt) { str('#<')  |  str('cardinality-less-than') }

      rule(:match_expression)    { 
        explicit_set.as(:superset_match) | 
        ( construction_expression >> cardinality_expression.maybe).as(:construction_set_match )  |
        ( logic_expression >> cardinality_expression.maybe ).as(:logic_set_match)
      }

      root(:match_expression)

    end
  end
end
