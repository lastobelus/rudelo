# Rudelo
[![Build Status](https://travis-ci.org/lastobelus/rudelo.png)](https://travis-ci.org/lastobelus/rudelo)

Provides Rufus::Decision::Matchers::SetLogic, for use with [rufus-decision][1]

## Requires ruby 1.9.3
Currently not working on 1.9.2 -- I will try to get this working at some point. I Probably won't get 1.8.7 working.



## Installation

    In Gemfile:

    # until 1.4.0 is published
    gem 'rufus-decision', git: 'https://github.com/jmettraux/rufus-decision.git'

    gem 'rudelo', git: "git://github.com/lastobelus/rudelo.git"

And then execute:

    $ bundle

## Usage

    TABLE = Rufus::Decision::Table.new(%{
        in:group, out:situation
        $(bob jeff mary alice ralph) & $in #= 2, company
        $(bob jeff mary alice ralph) & $in same-as $in #= 3, crowd
        $(bob jeff mary alice ralph) >= $in #> 3, exclusive-party
        $(bob jeff mary alice ralph) & $in < $in #> 5, PARTY!
        $(bob jeff mary alice ralph) & $in < $in #> 3, party
      })
    TABLE.matchers.unshift Rudelo::Matchers::SetLogic.new

    table.transform({'group' =>  "bob alice"})
    #=> {'group' => "bob alice", 'situation' => "company"}

    table.transform({'group' => "bob alice jeff"})
    #=> {'group' => "bob alice jeff", 'situation' => "crowd"})

    table.transform({'group' => "bob alice jeff ralph"})
    #=> {'group' => "bob alice jeff ralph", 'situation' => "exclusive-party"}

    table.transform({'group' => "bob alice jeff don"})
    #=> {'group' => "bob alice jeff don", 'situation' => "party"}

    table.transform({'group' => "bob alice jeff mary ralph don"})
    #=> {'group' => "bob alice jeff mary ralph don", 'situation' => "PARTY!"}

    table.transform({'group' => "bob alice jeff mary don bev"})
    #=> {'group' => "bob alice jeff mary don bev", 'situation' => "PARTY!"}

## Documentation

For a detailed description of the mini-language the set logic matcher uses, see [SET_LOGIC_MATCHER.md][4]

## Short-Circuiting

The current released version of rufus-decision does not provide for matchers to shortcircuit. This can cause errors if you have a SetLogic matcher followed by a String matcher. I have a branch of rufus-decision that does short-circuiting that is pending review, if you need to use it add this to your Gemfile:

```gem 'rufus-decision', git: 'https://github.com/lastobelus/rufus-decision.git', branch: 'short_circuit_matchers'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[1]: https://github.com/jmettraux/rufus-decision
[2]: https://github.com/lastobelus/rufus-decision/tree/pluggable_matchers
[3]: https://github.com/lastobelus/rufus-decision
[4]: https://github.com/lastobelus/rudelo/tree/SET_LOGIC_MATCHER.md