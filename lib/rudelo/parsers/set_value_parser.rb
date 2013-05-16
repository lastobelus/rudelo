require 'parslet' 

module Rudelo
  module Parsers

    module Space
      include Parslet
      rule(:space)             { match["\t "].repeat(1) }
      rule(:space?)            { space.maybe }
      def spaced_op(s)
        space >> str(s).as(:op)  >> space
      end      
      def spaced_op?(s)
        space? >> str(s).as(:op)  >> space?
      end
    end

    module Set
      include Parslet

      rule(:comma)             { str(',') }
      rule(:comma?)            { str(',').maybe }
      rule(:quote)             { match '"' }
      rule(:open_set)          { str('$(') }
      rule(:close_set)         { str(')') }

      rule(:unquoted_element)      { 
         (close_set.absent? >> space.absent? >> comma.absent? >> any).
        repeat(1).as(:element) }
      rule(:quoted_element)    { 
        (quote >> 
        (quote.absent? >> any).repeat.
        as(:element) >> 
        quote)}
      rule(:element)           { quoted_element | unquoted_element }
      rule(:element_delimiter)    { (comma | space) >> space? }


      rule(:bare_element_list) { 
        (element >> (element_delimiter >> element).repeat).
        as(:element_list)
      }

      rule(:explicit_set)      { 
        open_set >> space? >>
        bare_element_list >>
        space? >>
        close_set
      }
    end

    class SetValueParser < Parslet::Parser
      include Space
      include Set

      rule(:set_value)               { explicit_set | bare_element_list }
      root(:set_value)

    end
  end
end