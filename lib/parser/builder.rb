require 'term'
require 'type'

module Parser
  class Builder

    def term_expression(t, a, b, el)
      el[1]
    end

    def paren_term(t, a, b, el)
      el[2]
    end

    def term_seq(t, a, b, el)
      Term::Sequence.new(el[0], el[4])
    end

    def term_ascribe(t, a, b, el)
      Term::Ascribe.new(el[0], el[4])
    end

    def term_app(t, a, b, el)
      args = el[1].map(&:app_operand)
      args.inject(el[0]) { |x, y| Term::Application.new(x, y) }
    end

    def term_abs(t, a, b, el)
      Term::Abs.new(el[2].name, el[6], el[10])
    end

    def term_var(t, a, b, *)
      Term::Var.new(t[a ... b])
    end

    def term_true(*)
      Term::True
    end

    def term_false(*)
      Term::False
    end

    def term_if(t, a, b, el)
      Term::If.new(el[2], el[6], el[10])
    end

    def term_zero(*)
      Term::Zero
    end

    def term_succ(t, a, b, el)
      Term::Succ.new(el[2])
    end

    def term_pred(t, a, b, el)
      Term::Pred.new(el[2])
    end

    def term_iszero(t, a, b, el)
      Term::Iszero.new(el[2])
    end

    def term_unit(*)
      Term::Unit
    end

    def term_let(t, a, b, el)
      Term::Let.new(el[2].name, el[6], el[10])
    end

    def term_project(t, a, b, el)
      fields = el[1].map do |term|
        text = term.proj_field.text
        text =~ /^\d+$/ ? text.to_i : text
      end
      fields.inject(el[0]) { |term, field| Term::Project.new(term, field) }
    end

    def term_pair(t, a, b, el)
      Term::Pair.new(el[2], el[6])
    end

    def term_tuple(t, a, b, el)
      terms = [el[2]] + el[4].map(&:term_expr)
      Term::Tuple.new(terms)
    end

    def term_record(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:record_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.term_expr] }
      Term::Record.new(Hash[pairs])
    end

    def type_func(t, a, b, el)
      Type::Function.new(el[0], el[4])
    end

    def type_bool(*)
      Type::Boolean
    end

    def type_nat(*)
      Type::Natural
    end

    def type_unit(*)
      Type::Unit
    end

    def type_base(t, a, b, el)
      Type::Base.new(t[a ... b])
    end

    def type_pair(t, a, b, el)
      Type::Pair.new(el[0], el[4])
    end

    def type_tuple(t, a, b, el)
      types = [el[2]] + el[4].map(&:type_expr)
      Type::Tuple.new(types)
    end

    def type_record(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:rt_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.type_expr] }
      Type::Record.new(Hash[pairs])
    end

  end
end
