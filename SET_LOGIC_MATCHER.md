# Set Logic Matcher

The SetLogic matcher allows a decision table cell to match based on set logic between the decision table and the corresponding entry in the hash being transformed.


## Set Conversion on input hash

When a decision table cell contains a set expression, the corresponding value in the input is first converted to a set according to the following rules:

        $(bob, mary)       => Set["bob", "mary"]
        $(bob mary, jeff)  => Set["bob mary", "jeff"]
        $('bob rob', jeff) => Set["bob rob", "jeff"]
        ${r: ruby_code}    => eval ruby code, ignoring unless it returns a set
        ${other_column}    => apply set conversion to other_column
        $(${c1}, ${c2})    => Set["c1 contents", "c2 contents"]
        bob, mary          => Set["bob", "mary"]
        bob mary           => Set["bob mary"]
        'bob, mary', jeff  => Set["bob, mary", "jeff"]

## Decision Table Cell Syntax

1. The SetLogic matcher applies to any cell matching the regex:

  ```ruby
  /^\$\((.*)\)/
  ```

### Set Values

set logic expressions can contain Sets expressed in the following ways:

        $in                => the hash element with this column name, with set conversion applied
        $(${c1})           => the hash element named c1, with set conversion applied
        $(${in:c1})        => the row element named in:c1, assumed to be Decision Table Cell Syntax
        $(${out:c1})       => the row element named out:c1, with set conversion applied
        $()                => empty set
        $(bob, mary)       => Set["bob", "mary"]
        $(bob mary, jeff)  => Set["bob mary", "jeff"]
        $('bob rob', jeff) => Set["bob rob", "jeff"]
        $(*)               => The universal set
        $(r: ruby_code)    => eval ruby code, ignoring unless it returns a set

### Set Expressions
Set expressions can use the following operators:

#### Cardinality Operators

        #=
        cardinality-equals       => size of set ==
        #<
        cardinality-less-than    => size of set is less than X
        #>
        cardinality-greater-than => cardinality >

#### Set Construction Operators

        &|intersection     => intersection of sets
        +|union            => union of sets
        -|difference       => difference of sets
        ^                  => (set1 + set2) - (set1 & set2)

#### Set Logic Operators

        <|proper_subset    => proper_subset of sets
        >|proper_superset  => proper_superset of sets
        <=|subset          => subset of sets
        >=|superset        => superset of sets

        special case: if the cell contains only a set, it is equivalent to
        $in <= $(cell)

#### Set Expression Rules

* set expressions are evaluated left to right. There is no grouping; multiple columns in the decision table can be used to accomplish precedence
* cardinality operators must always be the last operator if present
* a cell can contain only one cardinality operator; use multiple cells for logic
* set construction operators may not follow set logic operators
* when a cardinality operator follows a logic operator, the sense is (set expression) && (cardinality expression applied to rightmost set in set expression)
* when a cardinality operator follows a (series of) set construction operator(s) it applies to the final constructed set
* if a cell contains a cardinality operator it matches the input if the cardinality expression is true
* if a cell contains a set logic operator it matches the input if the set logic expression is true
* if a cell contains set construction operators only it matches the input if the set expression results in a non-empty set
* if a cell contains no operators it matches the input if it is a superset of the corresponding input value, ie, it is equivalent to

        $in <= $(cell)

## Examples

        $(bob jeff mary) & $in #= 2
        => does not match (bob, jeff, mary)
        => matches (bob, mary) or (jeff, mary) etc.
        => does not match (bob) or (jeff) or (mary)

        $(bob, jeff, mary)
        => matches (bob)
        => matches (jeff, mary)
        => matches (bob, jeff, mary)
        => does not match (ralph, bob)

