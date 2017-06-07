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

    it 'parsers a base type' do
      expect(Parser.parse 'Float').to eq(Type::Base.new('Float'))
    end
  end
end
