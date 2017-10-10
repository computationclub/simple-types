require 'term'
require 'type'

def subtype_of?(subtype, supertype)
  return true if supertype == Type::Top # SA-TOP
  return true if subtype == supertype # S-REFL
  if subtype.is_a?(Type::Record) && supertype.is_a?(Type::Record)
    return supertype.members.all? do |field, type|
      subtype.members.key?(field) && subtype_of?(subtype.members[field], type)
    end
  end
  if subtype.is_a?(Type::Function) && supertype.is_a?(Type::Function)
    return (
      subtype_of?(supertype.from, subtype.from) &&
      subtype_of?(subtype.to, supertype.to)
    )
  end
  false
end

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
    raise TypeError, '💩 argument' unless subtype_of?(type_of(term.right, context), left_type.from)

    left_type.to
  when Term::Record
    Type::Record.new(term.members.map { |label, member| [label, type_of(member, context)] }.to_h)
  when Term::Project
    object_type = type_of(term.object, context)
    raise TypeError, 'not a record' unless object_type.is_a?(Type::Record)
    raise TypeError, "unknown field #{term.field}" unless object_type.members.key?(term.field)

    object_type.members.fetch(term.field)
  end
end
