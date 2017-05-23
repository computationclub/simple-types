require 'simple_types'

RSpec.describe 'type_of' do
  specify do
    expect(type_of(tru)).to eq(bool)
  end

  specify do
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
