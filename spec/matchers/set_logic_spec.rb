require_relative '../spec_helper'

require 'rudelo'
require 'rufus-decision'
describe "Rudelo::Matchers::SetLogic" do
  subject{Rudelo::Matchers::SetLogic.new}

  context "non-set cells never match" do
    specify{ expect(subject.matches?('5', '5')).to be_false}
    specify{ expect(subject.matches?(5, 4)).to be_false}
    specify{ expect(subject.matches?('bob', 'mary')).to be_false}
    specify{ expect(subject.matches?('bob', 'bob')).to be_false}
  end

  it "matches multiple values against multiple cells correctly" do
    cell1 = "$in same-as $(a, b, c)"
    cell2 = "$in same-as $(k, f, r)"
    expect(subject.matches?(cell1, 'a,b,c')).to be_true
    expect(subject.matches?(cell2, 'a,b,c')).to eq(:break)
    expect(subject.matches?(cell1, 'k,f,r')).to eq(:break)
    expect(subject.matches?(cell2, 'k,f,r')).to be_true
    expect(subject.matches?(cell1, 'a,b,c')).to be_true
    expect(subject.matches?(cell2, 'a,b,c')).to eq(:break)
  end

  it "matches explicit set syntax" do
    expect(subject.matches?('$(a, b, c)', 'a,b,c')).to be_true
    expect(subject.matches?('$(a, b, c)', 'a,b,d')).to eq(:break)
  end

  context "rufus-decision" do
    let(:table){
      table = Rufus::Decision::Table.new(%{
in:group, out:situation
"$(bob, jeff, mary, alice, ralph) & $in #= 2", company
"$(bob, jeff, mary, alice, ralph) & $in same-as $in #= 3", crowd
"$(bob, jeff, mary, alice, ralph) >= $in #> 3", exclusive-party
"$(bob, jeff, mary, alice, ralph) & $in < $in #> 5", PARTY!
"$(bob, jeff, mary, alice, ralph) & $in < $in #> 3", party
      })
      table.matchers.unshift Rudelo::Matchers::SetLogic.new
      table
    }
    it "transforms values" do
      expect(
        table.transform({'group' =>  "bob, alice"})
      ).to eq({'group' => "bob, alice", 'situation' => "company"})

      expect(
        table.transform({'group' => "bob, alice, jeff"})
      ).to eq({'group' => "bob, alice, jeff", 'situation' => "crowd"})

      expect(
        table.transform({'group' => "bob, alice, jeff, ralph"})
      ).to eq({'group' => "bob, alice, jeff, ralph", 'situation' => "exclusive-party"})

      expect(
        table.transform({'group' => "bob, alice, jeff, don"})
      ).to eq({'group' => "bob, alice, jeff, don", 'situation' => "party"})

      expect(
        table.transform({'group' => "bob, alice, jeff, mary, ralph, don"})
      ).to eq({'group' => "bob, alice, jeff, mary, ralph, don", 'situation' => "PARTY!"})

      expect(
        table.transform({'group' => "bob, alice, jeff, mary, don, bev"})
      ).to eq({'group' => "bob, alice, jeff, mary, don, bev", 'situation' => "PARTY!"})
    end
  end

end
