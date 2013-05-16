# Rudelo

## WIP
Rudelo is a work in progress:
  * [DONE]set value parser
  * [DONE]set value transform
  * [DONE]set expression parser
    * [DONE]logic
    * [DONE]construction
    * [DONE]cardinality
  * set expression transform
    * logic
    * construction
    * cardinality
  * rufus decision matcher

Provides Rufus::Decision::Matchers::SetLogic, for use with [rufus-decision][1]

Currently this requires the [pluggable_matchers branch][2] of lastobelus's [fork][3] of [rufus-decision][1]

## Installation

    In Gemfile:

    gem 'rudelo', git: "git://github.com/lastobelus/rudelo.git"

And then execute:

    $ bundle

## Usage

    TABLE = Rufus::Decision::Table.new(%{
      in:group, out:situation
      $(bob jeff mary alice ralph) & $in #= 2, company
      $(bob jeff mary alice ralph) & $in #= 3, crowd
      $(bob jeff mary alice ralph) >= $in #> 3, exclusive-party
      $(bob jeff mary alice ralph) & $in #> 3, party
      $(bob jeff mary alice ralph) & $in #> 4, PARTY!
    })

    TABLE.transform({group: "bob alice"})
    # => {group: "bob alice", situation: "company"}

    TABLE.transform({group: "bob alice jeff"})
    # => {group: "bob alice", situation: "crowd"}

    TABLE.transform({group: "bob alice jeff mary"})
    # => {group: "bob alice jeff mary don bev", situation: "exclusive-party"}

    TABLE.transform({group: "bob alice jeff don"})
    # => {group: "bob alice", situation: "party"}

    TABLE.transform({group: "bob alice jeff"})
    # => {group: "bob alice jeff mary", situation: "PARTY!"}

    TABLE.transform({group: "bob alice jeff mary don bev"})
    # => {group: "bob alice jeff mary don bev", situation: "PARTY!"}



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://github.com/jmettraux/rufus-decision
[2]: https://github.com/lastobelus/rufus-decision/tree/pluggable_matchers
[3]: https://github.com/lastobelus/rufus-decision