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

    def term_app(t, a, b, el)
      args = el[1].map(&:app_operand)
      ([el[0]] + args).inject { |s, t| Term::Application.new(s, t) }
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

    def type_func(t, a, b, el)
      Type::Function.new(el[0], el[4])
    end

    def type_bool(*)
      Type::Boolean
    end

  end
end
