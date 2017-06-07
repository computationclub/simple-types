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

  def expr(text)
    Parser.parse(text)
  end

  def empty_context
    {}
  end
end
