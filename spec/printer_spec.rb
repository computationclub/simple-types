require 'parser'

RSpec.describe 'printing' do
  [
    'x',
    'x y z',
    'x (y z)',
    'λx:Bool. x',
    'λx:Bool. λy:Bool → Bool. y x',
    'λx:Bool. x y',
    '(λx:Bool. x) y',
    'true',
    'false',
    'if true then x else y',
    'if (x y) then (x y z) else (x (y z))',
    'Bool',
    'Bool → Bool',
    'Bool → Bool → Bool',
    '(Bool → Bool) → Bool',

  ].each do |term|
    specify do
      expect(Parser.parse(term).inspect).to eq(term)
    end
  end
end
