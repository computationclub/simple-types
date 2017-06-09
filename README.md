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

| Syntax    | Node                                               |
| --------- | -------------------------------------------------- |
| `x`       | `Term::Var(name: string)`                          |
| `λx:T. t` | `Term::Abs(param: string, type: type, body: term)` |
| `t t`     | `Term::Application(left: term, right: term)`       |
| `T → T`   | `Type::Function(from: type, to: type)`             |

### Booleans

| Syntax               | Node                                                           |
| -------------------- | -------------------------------------------------------------- |
| `true`               | `Term::True`                                                   |
| `false`              | `Term::False`                                                  |
| `if t then t else t` | `Term::If(condition: term, consequent: term, alternate: term)` |
| `Bool`               | `Type::Boolean`                                                |

### Numeric

| Syntax     | Node                      |
| ---------- | ------------------------- |
| `0`        | `Term::Zero`              |
| `succ t`   | `Term::Succ(arg: term)`   |
| `pred t`   | `Term::Pred(arg: term)`   |
| `iszero t` | `Term::Iszero(arg: term)` |
| `Nat`      | `Type::Natural`           |

### Base types

| Syntax | Node                       |
| ------ | -------------------------- |
| `T`    | `Type::Base(name: string)` |

### Unit type

| Syntax | Node         |
| ------ | ------------ |
| `unit` | `Term::Unit` |
| `Unit` | `Type::Unit` |

### Sequencing

| Syntax  | Node                                      |
| ------- | ----------------------------------------- |
| `t ; t` | `Term::Sequence(first: term, last: term)` |

### Ascription

| Syntax   | Node                                    |
| -------- | --------------------------------------- |
| `t as T` | `Term::Ascribe(term: term, type: type)` |

### Let binding

| Syntax         | Node                                              |
| -------------- | ------------------------------------------------- |
| `let x=t in t` | `Term::Let(param: string, arg: term, body: term)` |

### Projection

| Syntax         | Node                                              |
| -------------- | ------------------------------------------------- |
| `t.1`, `t.foo` | `Term::Project(term: term, field: int \| string)` |

### Pairs

| Syntax     | Node                                     |
| ---------- | ---------------------------------------- |
| `{t \| t}` | `Term::Pair(left: term, right: term)`    |
| `T × T`    | `Type::Product(left: type, right: type)` |

### Tuples

| Syntax        | Node                           |
| ------------- | ------------------------------ |
| `{t, t, ...}` | `Term::Tuple(members: [term])` |
| `{T, T, ...}` | `Type::Tuple(members: [type])` |

### Records

| Syntax                  | Node                                      |
| ----------------------- | ----------------------------------------- |
| `{foo=t, bar=t, ...}`   | `Term::Record(members: {string => term})` |
| `{foo: T, bar: T, ...}` | `Type::Record(members: {string => type})` |

### Sums

In these terms, `clause` means `Term::CaseClause(param: string, body: term)`

| Syntax                             | Node                                                     |
| ---------------------------------- | -------------------------------------------------------- |
| `inl t`                            | `Term::Inl(term: term)`                                  |
| `inr t`                            | `Term::Inr(term: term)`                                  |
| `inl t as T`                       | `Term::Inl(term: term, type: type)`                      |
| `inr t as T`                       | `Term::Inr(term: term, type: type)`                      |
| `case t of inl x ⇒ t \| inr x ⇒ t` | `Term::SumCase(term: term, left: clause, right: clause)` |
| `T + T`                            | `Type::Sum(left: type, right: type)`                     |

### Variants

In these terms, `clause` means `Term::CaseClause(param: string, body: term)`

| Syntax                                        | Node                                                     |
| --------------------------------------------- | -------------------------------------------------------- |
| `<label=t> as T`                              | `Term::Tagged(label: string, term: term, type: type)`    |
| `case t of <foo=x> ⇒ t \| <bar=x> ⇒ t \| ...` | `Term::VarCase(term: term, clauses: {string => clause})` |
| `<foo: T, bar: T, ...>`                       | `Type::Variant(clauses: {string => type})`               |
