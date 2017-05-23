def type_of(term, context = {})
  case term
  when Term::True, Term::False
    Type::Boolean
  when Term::Var
    context.fetch(term.name) { raise TypeError, "unknown variable #{term.name}" }
  when Term::Abs
    Type::Function.new(
      term.type,
      type_of(term.body, context.merge(term.param => term.type))
    )
  when Term::If
    unless type_of(term.condition, context) == Type::Boolean
      raise TypeError, "non-boolean condition"
    end

    unless type_of(term.consequent, context) == type_of(term.alternate, context)
      raise TypeError, "mismatching arms"
    end

    type_of(term.consequent, context)
  when Term::Application
    left_type = type_of(term.left, context)
    raise TypeError, "non-abstraction" unless left_type.is_a?(Type::Function)
    raise TypeError, "💩 argument" unless left_type.from == type_of(term.right, context)

    left_type.to
  end
end

module Term
  True = Object.new
  False = Object.new
  Var = Struct.new(:name)
  Abs = Struct.new(:param, :type, :body)
  If = Struct.new(:condition, :consequent, :alternate)
  Application = Struct.new(:left, :right)
end

module Type
  Boolean = Object.new
  Function = Struct.new(:from, :to)
end

RSpec.describe "Typechecker" do
  describe '#type_of' do
    it 'returns a Boolean for the term True' do
      expect(type_of(tru)).to eq(bool)
    end

    it 'returns a Boolean for the term False' do
      expect(type_of(fls)).to eq(bool)
    end

    specify do
      expect { type_of(var('x'), empty_context) }.to raise_error(TypeError)
    end

    specify do
      expect(type_of(var('x'), 'x' => bool)).to eq(bool)
    end

    specify do
      expect(type_of(abs('x', bool, tru))).to eq(func(bool, bool))
    end

    specify do
      expect(type_of(abs('x', bool, var('x')))).to eq(func(bool, bool))
    end

    specify do
      expect { type_of(abs('x', bool, var('y'))) }.to raise_error(TypeError)
    end

    specify do
      expect(type_of(abs('x', bool, abs('y', bool, var('x'))))).to eq(func(bool, func(bool, bool)))
    end

    specify do
      expect(type_of(iff(tru, tru, fls))).to eq(bool)
    end

    specify do
      expect { type_of(iff(abs('x', bool, tru), tru, fls)) }.to raise_error(TypeError)
    end

    specify do
      f = abs('x', bool, tru)

      expect(type_of(iff(tru, f, f))).to eq(func(bool, bool))
    end

    specify do
      f = abs('x', bool, tru)

      expect { type_of(iff(tru, f, tru)) }.to raise_error(TypeError)
    end

    specify do
      expect(type_of(iff(tru, var('x'), tru), 'x' => bool)).to eq(bool)
    end

    specify do
      expect { type_of(app(tru, tru)) }.to raise_error(TypeError)
    end

    specify do
      expect(type_of(app(abs('x', bool, tru), tru))).to eq(bool)
    end

    specify do
      expect { type_of(app(abs('x', bool, tru), abs('x', bool, tru))) }.to raise_error(TypeError)
    end
  end

  def tru
    Term::True
  end

  def fls
    Term::False
  end

  def bool
    Type::Boolean
  end

  def func(from, to)
    Type::Function.new(from, to)
  end

  def app(left, right)
    Term::Application.new(left, right)
  end

  def iff(condition, consequent, alternate)
    Term::If.new(condition, consequent, alternate)
  end

  def abs(param, type, body)
    Term::Abs.new(param, type, body)
  end

  def var(name)
    Term::Var.new(name)
  end

  def empty_context
    {}
  end
end
