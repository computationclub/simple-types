require 'term'
require 'type'

module Parser
  class Builder

    def term_expression(t, a, b, el)
      el[1]
    end

    def paren_expr(t, a, b, el)
      el[2]
    end

    def term_app(t, a, b, el)
      args = el[1].map(&:atom)
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

    def type_top(*)
      Type::Top
    end

    def term_project(t, a, b, el)
      fields = el[1].map { |term| term.proj_field.text }
      fields.inject(el[0]) { |term, field| Term::Project.new(term, field) }
    end

    def term_record(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:record_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.control] }
      Term::Record.new(Hash[pairs])
    end

    def type_func(t, a, b, el)
      Type::Function.new(el[0], el[4])
    end

    def type_bool(*)
      Type::Boolean
    end

    def type_record(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:rt_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.type] }
      Type::Record.new(Hash[pairs])
    end

  end
end
