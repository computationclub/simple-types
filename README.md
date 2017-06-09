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

### Lambda calculus

- `Term::Var(name: string)`
- `Term::Abs(param: string, type: type, body: term)`
- `Term::Application(left: term, right: term)`
- `Type::Function(from: type, to: type)`

### Booleans

- `Term::True`
- `Term::False`
- `Term::If(condition: term, consequent: term, alternate: term)`
- `Type::Boolean`

### Numeric

- `Term::Zero`
- `Term::Succ(arg: term)`
- `Term::Pred(arg: term)`
- `Term::Iszero(arg: term)`
- `Type::Natural`

### Base types

- `Type::Base(name: string)`

### Unit type

- `Term::Unit`
- `Type::Unit`

### Sequencing

- `Term::Sequence(first: term, last: term)`

### Ascription

- `Term::Ascribe(term: term, type: type)`

### Let binding

- `Term::Let(param: string, arg: term, body: term)`

### Projection

- `Term::Project(term: term, field: int)`

### Pairs

- `Term::Pair(first: term, second: term)`
- `Type::Pair(first: type, second: type)`

### Tuples

- `Term::Tuple(members: [term])`
- `Type::Tuple(members: [type])`
