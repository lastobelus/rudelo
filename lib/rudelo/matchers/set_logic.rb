#--
# Copyright (c) 2013, Michael Johnston, lastobelus@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
#++

require 'rufus/decision/matcher'
require 'rudelo/parsers/set_logic_parser'
require 'rudelo/parsers/set_logic_transform'

module Rudelo
  module Matchers
    class SetLogic < Rufus::Decision::Matcher
      SYNTAX_EXPR = %r{\$\([^)]*\)|\$in}
      attr_accessor :force

      def should_match?(cell, value)
        ! (cell =~ SYNTAX_EXPR).nil?
      end

      def matches?(cell, value)
        evaluator = ast(cell)
        return false if evaluator.nil?
        in_set = value_transform.apply(value_parser.parse(value))
        ast(cell).eval(in_set)
      end

      def cell_substitution?
        true
      end

      def asts
        @asts ||= {}
      end

      def logic_parser
        @logic_parser ||= Rudelo::Parsers::SetLogicParser.new
      end

      def logic_transform
        @logic_transform ||= Rudelo::Parsers::SetLogicTransform.new
      end

      def value_parser
        @value_parser ||= Rudelo::Parsers::SetValueParser.new
      end

      def value_transform
        @value_transform ||= Rudelo::Parsers::SetLogicTransform.new
      end

      def ast(cell)
        asts[cell] ||= begin
          logic_transform.apply(logic_parser.parse(cell))
        rescue
          raise if force
          nil
        end
      end

    end
  end
end
