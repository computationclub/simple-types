# Chapter 10: Simple Types

A Ruby implementation of the type checker described in Chapter 10 of Benjamin
C. Pierce's "Types and Programming Languages" mobbed during a meeting of
[London Computation Club](http://london.computation.club) on Tuesday, 23rd May
2017.


## Installation

    git clone git://github.com/computationclub/simple-types.git
    cd simple-types
    bundle install
    make


## AST nodes

### Terms

Lambda calculus:

- `Term::Var(name: string)`
- `Term::Abs(param: string, type: type, body: term)`
- `Term::Application(left: term, right: term)`

Booleans:

- `Term::True`
- `Term::False`
- `Term::If(condition: term, consequent: term, alternate: term)`

Numeric:

- `Term::Zero`
- `Term::Succ(arg: term)`
- `Term::Pred(arg: term)`
- `Term::Iszero(arg: term)`

Unit type:

- `Term::Unit`

Sequencing:

- `Term::Sequence(first: term, last: term)`

Ascription:

- `Term::Ascribe(term: term, type: type)`

Let binding:

- `Term::Let(param: string, arg: term, body: term)`

Pairs:

- `Term::Project(term: term, field: int)`
- `Term::Pair(first: term, second: term)`

### Types

Lambda calculus:

- `Type::Function(from: type, to: type)`

Booleans:

- `Type::Boolean`

Numeric:

- `Type::Natural`

Base types:

- `Type::Base(name: string)`

Unit type:

- `Type::Unit`

Pairs:

- `Type::Pair(first: type, second: type)`

Tuples:

- `Type::Tuple(members: [type])`
