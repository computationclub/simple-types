require 'parser'

RSpec.describe Parser do
  describe 'terms' do
    it 'parses a variable' do
      expect(Parser.parse 'x').to eq(Term::Var.new('x'))
    end

    it 'parses an abstraction' do
      expect(Parser.parse 'λx:Bool. x').to eq(
        Term::Abs.new('x', Type::Boolean, Term::Var.new('x'))
      )
    end

    it 'parses a 2-term application' do
      expect(Parser.parse('x y')).to eq(
        Term::Application.new(Term::Var.new('x'), Term::Var.new('y'))
      )
    end

    it 'parses a redex' do
      expect(Parser.parse('(λx:Bool. x) y')).to eq(
        Term::Application.new(
          Term::Abs.new('x', Type::Boolean, Term::Var.new('x')),
          Term::Var.new('y'))
      )
    end

    it 'parses an abstraction containing an application' do
      expect(Parser.parse('λx:Bool. x y')).to eq(
        Term::Abs.new('x', Type::Boolean,
          Term::Application.new(Term::Var.new('x'), Term::Var.new('y')))
      )
    end

    it 'parses an ambiguous 3-term application' do
      expect(Parser.parse('x y z')).to eq(
        Term::Application.new(
          Term::Application.new(Term::Var.new('x'), Term::Var.new('y')),
          Term::Var.new('z'))
      )
    end

    it 'parses a left-associated 3-term application' do
      expect(Parser.parse('(x y) z')).to eq(
        Term::Application.new(
          Term::Application.new(Term::Var.new('x'), Term::Var.new('y')),
          Term::Var.new('z'))
      )
    end

    it 'parses a right-associated 3-term application' do
      expect(Parser.parse('x (y z)')).to eq(
        Term::Application.new(
          Term::Var.new('x'),
          Term::Application.new(Term::Var.new('y'), Term::Var.new('z')))
      )
    end

    it 'parses an application taking an abstraction' do
      expect(Parser.parse 'x λy:Bool. y').to eq(
        Term::Application.new(
          Term::Var.new('x'),
          Term::Abs.new('y', Type::Boolean, Term::Var.new('y')))
      )
    end

    it 'parses true' do
      expect(Parser.parse 'true').to eq(Term::True)
    end

    it 'parses false' do
      expect(Parser.parse 'false').to eq(Term::False)
    end

    it 'parses an if-expression' do
      expect(Parser.parse 'if x then y else z').to eq(
        Term::If.new(Term::Var.new('x'), Term::Var.new('y'), Term::Var.new('z'))
      )
    end

    it 'parses a nested if-expression' do
      expect(Parser.parse 'if x then if a then b else c else z').to eq(
        Term::If.new(
          Term::Var.new('x'),
          Term::If.new(Term::Var.new('a'), Term::Var.new('b'), Term::Var.new('c')),
          Term::Var.new('z'))
      )
    end

    it 'parses an if-expression containing an abstraction' do
      expect(Parser.parse 'if (λx:Bool. x) then y else z').to eq(
        Term::If.new(
          Term::Abs.new('x', Type::Boolean, Term::Var.new('x')),
          Term::Var.new('y'),
          Term::Var.new('z'))
      )
    end

    it 'parses zero' do
      expect(Parser.parse '0').to eq(Term::Zero)
    end

    it 'parses succ' do
      expect(Parser.parse 'succ 0').to eq(Term::Succ.new(Term::Zero))
    end

    it 'parses pred' do
      expect(Parser.parse 'pred 0').to eq(Term::Pred.new(Term::Zero))
    end

    it 'parses iszero' do
      expect(Parser.parse 'iszero 0').to eq(Term::Iszero.new(Term::Zero))
    end

    it 'parses unit' do
      expect(Parser.parse 'unit').to eq(Term::Unit)
    end

    it 'parses a sequence' do
      expect(Parser.parse 'x ; y').to eq(
        Term::Sequence.new(Term::Var.new('x'), Term::Var.new('y'))
      )
    end

    it 'parses sequencing with lower precedence than application' do
      expect(Parser.parse 'x ; y z').to eq(
        Term::Sequence.new(
          Term::Var.new('x'),
          Term::Application.new(Term::Var.new('y'), Term::Var.new('z')))
      )
    end

    it 'parses sequencing with lower precedence than abstraction' do
      expect(Parser.parse 'λx:Bool. x ; y').to eq(
        Term::Sequence.new(
          Term::Abs.new('x', Type::Boolean, Term::Var.new('x')),
          Term::Var.new('y'))
      )
    end

    it 'parses sequencing as lower precedence than if-expressions' do
      expect(Parser.parse 'if x then y else a ; b').to eq(
        Term::Sequence.new(
          Term::If.new(Term::Var.new('x'), Term::Var.new('y'), Term::Var.new('a')),
          Term::Var.new('b'))
      )
    end

    it 'parses ascription' do
      expect(Parser.parse 'x as Bool').to eq(
        Term::Ascribe.new(Term::Var.new('x'), Type::Boolean)
      )
    end

    it 'parses ascription with lower precedence than application' do
      expect(Parser.parse 'x y as Bool').to eq(
        Term::Ascribe.new(
          Term::Application.new(Term::Var.new('x'), Term::Var.new('y')),
          Type::Boolean)
      )
    end

    it 'parses ascription with higher precedence than sequencing' do
      expect(Parser.parse 'x ; y as Bool').to eq(
        Term::Sequence.new(
          Term::Var.new('x'),
          Term::Ascribe.new(Term::Var.new('y'), Type::Boolean))
      )
    end

    it 'parses a let-binding' do
      expect(Parser.parse 'let x = y z in x').to eq(
        Term::Let.new('x',
                      Term::Application.new(Term::Var.new('y'), Term::Var.new('z')),
                      Term::Var.new('x'))
      )
    end

    it 'parses a pair' do
      expect(Parser.parse '{x y | z}').to eq(
        Term::Pair.new(
          Term::Application.new(Term::Var.new('x'), Term::Var.new('y')),
          Term::Var.new('z'))
      )
    end

    it 'parses a pair projection' do
      expect(Parser.parse 'x.1').to eq(Term::Project.new(Term::Var.new('x'), 1))
    end

    it 'parses a chain of pair projections' do
      expect(Parser.parse '{{x | y} | z}.1.2').to eq(
        Term::Project.new(
          Term::Project.new(
            Term::Pair.new(
              Term::Pair.new(Term::Var.new('x'), Term::Var.new('y')),
              Term::Var.new('z')),
            1),
          2)
      )
    end

    it 'parses projection with higher precedence than application' do
      expect(Parser.parse 'x y.1').to eq(
        Term::Application.new(
          Term::Var.new('x'),
          Term::Project.new(Term::Var.new('y'), 1))
      )
    end

    it 'parses projection within an if-expression' do
      expect(Parser.parse 'if x then y else z.2').to eq(
        Term::If.new(
          Term::Var.new('x'),
          Term::Var.new('y'),
          Term::Project.new(Term::Var.new('z'), 2))
      )
    end

    it 'parses a tuple' do
      expect(Parser.parse '{0, λx:Nat. unit, {true | unit}}').to eq(
        Term::Tuple.new([
          Term::Zero,
          Term::Abs.new('x', Type::Natural, Term::Unit),
          Term::Pair.new(Term::True, Term::Unit)
        ])
      )
    end

    it 'parses a tuple projection' do
      expect(Parser.parse 'x.789').to eq(Term::Project.new(Term::Var.new('x'), 789))
    end

    it 'parses a record' do
      expect(Parser.parse '{foo=x, bar=0}').to eq(
        Term::Record.new(
          'foo' => Term::Var.new('x'),
          'bar' => Term::Zero)
      )
    end

    it 'parses a record projection' do
      expect(Parser.parse 'x.foo').to eq(Term::Project.new(Term::Var.new('x'), 'foo'))
    end

    it 'parses a chain of record projections' do
      expect(Parser.parse 'x.foo.bar').to eq(
        Term::Project.new(
          Term::Project.new(Term::Var.new('x'), 'foo'),
          'bar')
      )
    end

    it 'parses a chain of record and tuple projections' do
      expect(Parser.parse 'x.foo.3.bar').to eq(
        Term::Project.new(
          Term::Project.new(
            Term::Project.new(Term::Var.new('x'), 'foo'),
            3),
          'bar')
      )
    end

    it 'parses an inl term' do
      expect(Parser.parse 'inl x').to eq(Term::Inl.new(Term::Var.new('x')))
    end

    it 'parses an inr term' do
      expect(Parser.parse 'inr x').to eq(Term::Inr.new(Term::Var.new('x')))
    end

    it 'parses an inr term with ascription' do
      expect(Parser.parse 'inr x as Nat').to eq(
        Term::Inr.new(Term::Var.new('x'), Type::Natural)
      )
    end

    it 'parses a sum case expression' do
      expect(Parser.parse 'case x of inl a ⇒ true | inr b ⇒ false').to eq(
        Term::SumCase.new(
          Term::Var.new('x'),
          Term::SumClause.new('a', Term::True),
          Term::SumClause.new('b', Term::False))
      )
    end
  end

  describe 'types' do
    it 'parses the Bool type' do
      expect(Parser.parse 'Bool').to eq(Type::Boolean)
    end

    it 'parses a 2-term function type' do
      expect(Parser.parse 'Bool → Bool').to eq(
        Type::Function.new(Type::Boolean, Type::Boolean)
      )
    end

    it 'parses an ambiguous 3-term function type' do
      expect(Parser.parse 'Bool → Bool → Bool').to eq(
        Type::Function.new(
          Type::Boolean,
          Type::Function.new(Type::Boolean, Type::Boolean))
      )
    end

    it 'parses a right-associated 3-term function type' do
      expect(Parser.parse 'Bool → (Bool → Bool)').to eq(
        Type::Function.new(
          Type::Boolean,
          Type::Function.new(Type::Boolean, Type::Boolean))
      )
    end

    it 'parses a left-associated 3-term function type' do
      expect(Parser.parse '(Bool → Bool) → Bool').to eq(
        Type::Function.new(
          Type::Function.new(Type::Boolean, Type::Boolean),
          Type::Boolean)
      )
    end

    it 'parses a function from booleans to numbers' do
      expect(Parser.parse('Bool → Nat')).to eq(
        Type::Function.new(Type::Boolean, Type::Natural)
      )
    end

    it 'parses a base type' do
      expect(Parser.parse 'Float').to eq(Type::Base.new('Float'))
    end

    it 'parses Unit' do
      expect(Parser.parse 'Unit').to eq(Type::Unit)
    end

    it 'parses the pair type' do
      expect(Parser.parse 'Nat × Bool').to eq(
        Type::Product.new(Type::Natural, Type::Boolean)
      )
    end

    it 'parses the pair type with higher precedence than the function type' do
      expect(Parser.parse 'Nat → Bool × Nat').to eq(
        Type::Function.new(
          Type::Natural,
          Type::Product.new(Type::Boolean, Type::Natural))
      )
    end

    it 'parses a tuple type' do
      expect(Parser.parse '{Nat, Nat → Unit, Bool × Unit}').to eq(
        Type::Tuple.new([
          Type::Natural,
          Type::Function.new(Type::Natural, Type::Unit),
          Type::Product.new(Type::Boolean, Type::Unit)
        ])
      )
    end

    it 'parses a record type' do
      expect(Parser.parse '{foo: Bool → Unit, bar: Nat}').to eq(
        Type::Record.new(
          'foo' => Type::Function.new(Type::Boolean, Type::Unit),
          'bar' => Type::Natural)
      )
    end

    it 'parses the sum type' do
      expect(Parser.parse 'Nat + Bool').to eq(
        Type::Sum.new(Type::Natural, Type::Boolean)
      )
    end

    it 'parses the sum type with higher precedence than the function type' do
      expect(Parser.parse 'Nat → Bool + Nat').to eq(
        Type::Function.new(
          Type::Natural,
          Type::Sum.new(Type::Boolean, Type::Natural))
      )
    end

    it 'parses the sum type with lower precedence than the pair type' do
      expect(Parser.parse 'Nat × Bool + Nat').to eq(
        Type::Sum.new(
          Type::Product.new(Type::Natural, Type::Boolean),
          Type::Natural)
      )
    end
  end
end
