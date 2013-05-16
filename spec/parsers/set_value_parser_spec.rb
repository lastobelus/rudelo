require_relative '../spec_helper'

require 'rudelo/parsers/set_value_parser'

describe "Rudelo::Parsers::SetValueParser" do
  let(:parser) { Rudelo::Parsers::SetValueParser.new }
  context "set parsing" do
    it "parses bare sets" do
      expect(parser).to  parse(%Q{bob, mary}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"}
        ]
      })

      expect(parser).to  parse(%Q{bob}, trace: true).as({
        element_list: 
          {element: "bob"}
        
      })

      expect(parser).to  parse(%Q{bob, mary, jeff}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"},
          {element: "jeff"}
        ]
      })

      expect(parser).to  parse(%Q{bob mary}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"}
        ]
      })

      expect(parser).to  parse(%Q{bob    mary, ralph}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"},
          {element: "ralph"}
        ]
      })

      expect(parser).to  parse(%Q{"bob    mary", ralph}, trace: true).as({
        element_list: [
          {element: "bob    mary"},
          {element: "ralph"}
        ]
      })

      expect(parser).to  parse(%Q{"bob, mary", ralph}, trace: true).as({
        element_list: [
          {element: "bob, mary"},
          {element: "ralph"}
        ]
      })
    end

    it "parses explicit sets" do
      expect(parser).to  parse(%Q{$(bob, mary)}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"}
        ]
      })
      expect(parser).to  parse(%Q{$("bob", mary)}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"}
        ]
      })
      expect(parser).to  parse(%Q{$("bob)dad", mary)}, trace: true).as({
        element_list: [
          {element: "bob)dad"},
          {element: "mary"}
        ]
      })
      expect(parser).to  parse(%Q{$("bob", mary jeff)}, trace: true).as({
        element_list: [
          {element: "bob"},
          {element: "mary"},
          {element: "jeff"},          
        ]
      })

    end

  end
end