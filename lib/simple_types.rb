require 'term'
require 'type'

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
