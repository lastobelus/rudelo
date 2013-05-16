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

      ########  Cardinality  Expressions ########
      rule(:cardinality_eq) { str('#=')  |  str('cardinality-equals') }
      rule(:cardinality_gt) { str('#>')  |  str('cardinality-greater-than') }
      rule(:cardinality_lt) { str('#<')  |  str('cardinality-less-than') }
      rule(:cardinality_operator) {
        cardinality_eq | cardinality_gt | cardinality_lt
      }
      rule(:cardinality_expression) {(
          cardinality_operator.as(:operator) >> 
          space? >> 
          integer.as(:qty)
        ).as(:cardinality_expression)
      }

      ########  Set Construction  Expressions ########
      
      rule(:set_construction_operator){
        spaced_op?('&')  | spaced_op('intersection') |
        spaced_op?('+') | spaced_op('union') |
        spaced_op?('-') | spaced_op('difference') |
        spaced_op?('^') | spaced_op('exclusive')
      }
      rule(:set_construction_expression){
        (set.as(:left) >>(set_construction_operator >> set).repeat(1).as(:right)).as(:set_construction_expression)
      }


      ########  Set Logic  Expressions ########
      rule(:set_expression) { set_construction_expression | set }
      rule(:set_logic_operator){
        spaced_op?('<', '=')  | spaced_op('subset') |
        spaced_op?('>', '=') | spaced_op('superset') |
        spaced_op?('<=') | spaced_op('proper-subset') |
        spaced_op?('>=') | spaced_op('proper-superset') 
       }
      rule(:set_logic_expression){
        (set_expression.as(:left) >> set_logic_operator >> set.as(:right)).as(:set_logic_expression)
      }




      rule(:match_expression)    { space? >> (

        ( set_logic_expression >> 
          (space >> cardinality_expression).maybe ).
        as(:logic_set_match) |

        ( set_construction_expression >> 
          (space >> cardinality_expression).maybe).
        as(:construction_set_match )  |

        explicit_set.as(:superset_match) |

        cardinality_expression.as(:cardinality_match)
        
      ) >> space? }

      root(:match_expression)

    end
  end
end
