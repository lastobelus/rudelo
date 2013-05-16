module Rudelo
  module Parsers
    class SetValueTransform < Parslet::Transform
      rule(:element => simple(:element)) { element.to_s }
      rule(:element_list => subtree(:element_list)) do
        Set[*element_list]
      end
    end
  end
end