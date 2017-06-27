require 'term'
require 'type'

def type_of(term, context = {})
  case term
  when Term::True, Term::False
    Type::Boolean
  when Term::Var
    raise TypeError, "unknown variable #{term.name}" unless context.key?(term.name)

    context.fetch(term.name)
  when Term::Abs
    context_prime = context.merge(term.param => term.type)

    Type::Function.new(term.type, type_of(term.body, context_prime))
  when Term::If
    condition_type = type_of(term.condition, context)
    raise TypeError, 'non-boolean condition' unless condition_type == Type::Boolean

    consequent_type = type_of(term.consequent, context)
    alternate_type = type_of(term.alternate, context)
    raise TypeError, 'mismatching arms' unless consequent_type == alternate_type

    consequent_type
  when Term::Application
    left_type = type_of(term.left, context)
    raise TypeError, 'non-abstraction' unless left_type.is_a?(Type::Function)
    raise TypeError, '💩 argument' unless left_type.from == type_of(term.right, context)

    left_type.to
  when Term::Pair
    left_type = type_of(term.left, context)
    right_type = type_of(term.right, context)

    Type::Product.new(left_type, right_type)
  when Term::Project
    object_type = type_of(term.object, context)
    raise TypeError, 'not a pair' unless object_type.is_a?(Type::Product)

    case term.field
    when 1
      object_type.left
    when 2
      object_type.right
    else
      raise TypeError, 'out of bounds'
    end
  when Term::Inl
    sum_type = term.type
    raise TypeError, 'inl ascription must contains Sum type' unless sum_type.is_a?(Type::Sum)

    term_type = type_of(term.term, context)
    raise TypeError, 'inl term must match left side of Sum type' unless term_type == sum_type.left

    sum_type
  when Term::Inr
    sum_type = term.type
    raise TypeError, 'inr ascription must contains Sum type' unless sum_type.is_a?(Type::Sum)

    term_type = type_of(term.term, context)
    raise TypeError, 'inr term must match right side of Sum type' unless term_type == sum_type.right

    sum_type
  when Term::SumCase
    sum_type = type_of(term.term, context)
    raise TypeError, 'the term of a Sum case must be a Sum type' unless sum_type.is_a?(Type::Sum)

    left_type = type_of(term.left.body, context.merge(term.left.param => sum_type.left))
    right_type = type_of(term.right.body, context.merge(term.right.param => sum_type.right))

    raise TypeError, 'the two arms must match' unless left_type == right_type

    left_type
  end
end
