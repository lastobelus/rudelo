require 'parslet' 

module Rudelo
  module Parsers
    class SetValueParser < Parslet::Parser
      rule(:space)             { match('\s').repeat(1) }
      rule(:space?)            { space.maybe }

      rule(:comma)             { match(',') }
      rule(:comma?)            { match(',').maybe }
      rule(:quote)             { match '"' }

      rule(:bare_element)      { (space.absent? >> comma.absent? >> any).
        repeat(1).as(:element) }
      rule(:quoted_element)    { (quote >> 
        (quote.absent? >> any).repeat.as(:element) >> 
        quote)}
      rule(:element)           { (quoted_element | bare_element) }
      rule(:bare_delimiter)    { (comma | space) >> space? }
      rule(:bare_element_list) { 
        (element >> (bare_delimiter >> element).repeat).
        as(:element_list)
      }

      rule(:integer)           { match('[0-9]').repeat(1) }


      rule(:set)               { bare_element_list }
      root(:set)
    end
  end
end