require 'parslet' 

module Rudelo
  module Parsers
    class SetValueParser < Parslet::Parser
      rule(:space)             { match["\t "].repeat(1) }
      rule(:space?)            { space.maybe }

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
      rule(:delimiter)    { (comma | space) >> space? }
      rule(:bare_element_list) { 
        (element >> (delimiter >> element).repeat).
        as(:element_list)
      }

      rule(:integer)           { match('[0-9]').repeat(1) }

      rule(:explicit_set)      { 
        open_set >> space? >>
        bare_element_list >> 
        close_set >> space?
      }

      rule(:set)               { explicit_set | bare_element_list }
      root(:set)


    end
  end
end