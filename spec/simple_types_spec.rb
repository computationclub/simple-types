require 'simple_types'
require 'parser'

def expr(text)
  Parser.parse(text)
end

RSpec.describe 'subtype_of?' do

  RSpec::Matchers.define :be_subtype_of do |right|
    match do |left|
      expect(subtype_of?(expr(left), expr(right))).to be_truthy
    end
  end

  specify do
    expect('Bool').to be_subtype_of('Bool')
  end

  specify do
    expect('Bool').to be_subtype_of('Top')
  end

  specify do
    expect('Top').not_to be_subtype_of('Bool')
  end

  describe "SA-RCD" do
    specify do
      expect('{x:Bool, y:Bool}').to be_subtype_of('{y:Bool, x:Bool}')
    end

    specify do
      expect('{x:Bool, y:Bool}').to be_subtype_of('{x:Bool}')
    end

    specify do
      expect('{x:Bool}').not_to be_subtype_of('{x:Bool, y:Bool}')
    end

    specify do
      expect('{x:Bool}').to be_subtype_of('{x:Top}')
    end

    specify do
      expect('{x:Top}').not_to be_subtype_of('{x:Bool}')
    end

    specify do
      expect('{x:{a:Bool, b:Bool}}').to be_subtype_of('{x:{a:Bool}}')
    end

    specify do
      expect('{x:{a:Bool}}').not_to be_subtype_of('{x:{a:Bool, b:Bool}}')
    end

    specify do
      expect('{x:Bool, y:Bool, z:Bool}').to be_subtype_of('{y:Top, x:Top}')
    end
  end

  describe 'SA-ARROW' do
    specify do
      expect('Bool -> Bool').to be_subtype_of('Bool -> Bool')
    end

    specify do
      expect('Bool -> Bool').to be_subtype_of('Bool -> Top')
    end

    specify do
      expect('Top -> Bool').to be_subtype_of('Bool -> Bool')
    end

    specify do
      expect('Bool -> Top').not_to be_subtype_of('Bool -> Bool')
    end

    specify do
      expect('Bool -> Bool').not_to be_subtype_of('Top -> Bool')
    end
  end
end

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
    expect { type_of(expr '{foo=true, bar=λx:Bool. true}.baz') }.to raise_error(TypeError)
  end

  specify do
    expect(type_of(expr '(λr:{x:Bool}. r.x) {x=true, y=false}')).to eq(expr 'Bool')
  end

  specify do
    expect { type_of(expr '(λr:{x:Bool, y:Bool}. r.x) {x=true}') }.to raise_error(TypeError)
  end

  def empty_context
    {}
  end
end

RSpec.describe 'join' do
  specify do
    expect(join(expr('Bool'), expr('Bool'))).to eq(expr('Bool'))
  end

  specify do
    expect(join(expr('Bool'), expr('Top'))).to eq(expr('Top'))
  end

  specify do
    expect(join(expr('Top'), expr('Bool'))).to eq(expr('Top'))
  end

  specify do
    expect(join(expr('Bool'), expr('{x:Bool}'))).to eq(expr('Top'))
  end

  describe 'records' do
    specify do
      expect(join(expr('{x:Bool, y:Bool}'), expr('{x:Bool, z:Bool}'))).to eq(expr('{x:Bool}'))
    end

    specify do
      expect(join(expr('{x:Bool, y:Bool}'), expr('{x:{a:Bool}, z:Bool}'))).to eq(expr('{x:Top}'))
    end
  end
end
