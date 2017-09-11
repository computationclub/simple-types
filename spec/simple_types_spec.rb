require 'simple_types'
require 'parser'

RSpec.describe 'type_of' do
  specify do
    expect(type_of(expr 'true')).to eq(expr 'Bool')
  end

  specify do
    expect(type_of(expr 'false')).to eq(expr 'Bool')
  end

  specify do
    expect { type_of(expr('x'), empty_context) }.to raise_error(TypeError, /unknown variable/)
  end

  specify do
    expect(type_of(expr('x'), 'x' => expr('Bool'))).to eq(expr 'Bool')
  end

  specify do
    expect(type_of(expr 'λx:Bool. true')).to eq(expr 'Bool → Bool')
  end

  specify do
    expect(type_of(expr 'λx:Bool. x')).to eq(expr 'Bool → Bool')
  end

  specify do
    expect { type_of(expr 'λx:Bool. y') }.to raise_error(TypeError, /unknown variable/)
  end

  specify do
    expect(type_of(expr 'λx:Bool. λy:Bool. x')).to eq(expr 'Bool → Bool → Bool')
  end

  specify do
    expect(type_of(expr 'if true then true else false')).to eq(expr 'Bool')
  end

  specify do
    expect { type_of(expr 'if (λx:Bool. true) then true else false') }.to raise_error(TypeError, /non-boolean condition/)
  end

  specify do
    expect(type_of(expr 'if true then (λx:Bool. true) else (λx:Bool. true)')).to eq(expr 'Bool → Bool')
  end

  specify do
    expect { type_of(expr 'if true then (λx:Bool. true) else true') }.to raise_error(TypeError, /mismatching arms/)
  end

  specify do
    expect(type_of(expr('if true then x else true'), 'x' => expr('Bool'))).to eq(expr 'Bool')
  end

  specify do
    expect { type_of(expr 'true true') }.to raise_error(TypeError, /non-abstraction/)
  end

  specify do
    expect(type_of(expr '(λx:Bool. true) true')).to eq(expr 'Bool')
  end

  specify do
    expect { type_of(expr '(λx:Bool. true) (λx:Bool. true)') }.to raise_error(TypeError, /💩 argument/)
  end

  specify do
    expect(type_of(expr '{ true | true }')).to eq(expr 'Bool × Bool')
  end

  specify do
    expect(type_of(expr '{ true | { if true then false else true | false } }')).to eq(expr 'Bool × Bool × Bool')
  end

  specify do
    expect(type_of(expr '{ true | (λx:Bool. true) }.1')).to eq(expr 'Bool')
  end

  specify do
    expect(type_of(expr '{ true | (λx:Bool. true) }.2')).to eq(expr 'Bool → Bool')
  end

  specify do
    expect(type_of(expr '{foo=true, bar=λx:Bool. true}')).to eq(expr '{foo: Bool, bar: Bool → Bool}')
  end

  specify do
    expect(type_of(expr '{foo=true, bar=λx:Bool. true}.foo')).to eq(expr 'Bool')
  end

  specify do
    expect(type_of(expr '{foo=true, bar=λx:Bool. true}.bar')).to eq(expr 'Bool → Bool')
  end

  specify do
    expect { type_of(expr 'true.1') }.to raise_error(TypeError)
  end

  specify do
    expect { type_of(expr '{ true | false }.3') }.to raise_error(TypeError)
  end

  specify do
    expect { type_of(expr '{foo=true, bar=λx:Bool. true}.baz') }.to raise_error(TypeError)
  end

  specify do
    expect(type_of(expr 'inl true as Bool + (Bool × Bool)')).to eq(expr 'Bool + (Bool × Bool)')
  end

  specify do
    expect { type_of(expr 'inl { true | false } as Bool + (Bool × Bool)') }.to raise_error(TypeError)
  end

  specify do
    expect { type_of(expr 'inl true as Bool') }.to raise_error(TypeError)
  end

  specify do
    expect(type_of(expr 'inr true as (Bool × Bool) + Bool')).to eq(expr '(Bool × Bool) + Bool')
  end

  specify do
    expect { type_of(expr 'inr { true | false } as (Bool × Bool) + Bool') }.to raise_error(TypeError)
  end

  specify do
    expect { type_of(expr 'inr true as Bool') }.to raise_error(TypeError)
  end

  specify do
    expect(type_of(expr 'case inl true as Bool + (Bool × Bool) of inl b => b | inr p => p.1')).to eq(expr 'Bool')
  end

  specify do
    expect { type_of(expr 'case true of inl b => b | inr p => p.1') }.to raise_error(TypeError)
  end

  specify do
    expect { type_of(expr 'case inl true as Bool + (Bool × Bool) of inl b => b | inr p => p') }.to raise_error(TypeError)
  end

  def expr(text)
    Parser.parse(text)
  end

  def empty_context
    {}
  end
end
