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

    def term_seq(t, a, b, el)
      Term::Sequence.new(el[0], el[4])
    end

    def term_ascribe(t, a, b, el)
      term, type = el[0], el[4]
      case term
      when Term::Inl then Term::Inl.new(term.term, type)
      when Term::Inr then Term::Inr.new(term.term, type)
      else                Term::Ascribe.new(term, type)
      end
    end

    def term_tagged(t, a, b, el)
      Term::Tagged.new(el[2].text, el[6], el[12])
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
      terms = [el[2]] + el[4].map(&:control)
      Term::Tuple.new(terms)
    end

    def term_record(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:record_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.control] }
      Term::Record.new(Hash[pairs])
    end

    def term_inject(t, a, b, el)
      case el[0].text
      when 'inl' then Term::Inl.new(el[2])
      when 'inr' then Term::Inr.new(el[2])
      end
    end

    def term_sum_case(t, a, b, el)
      Term::SumCase.new(el[2], el[8], el[14])
    end

    def term_sum_clause(t, a, b, el)
      Term::CaseClause.new(el[0].name, el[4])
    end

    def term_var_case(t, a, b, el)
      clauses = [el[6]] + el[7].map(&:var_clause)
      Term::VarCase.new(el[2], Hash[clauses])
    end

    def term_var_clause(t, a, b, el)
      [el[2].text, Term::CaseClause.new(el[6].name, el[12])]
    end

    def term_nil(t, a, b, el)
      Term::Nil.new(el[4])
    end

    def term_cons(t, a, b, el)
      Term::Cons.new(el[4], el[8], el[10])
    end

    def term_isnil(t, a, b, el)
      Term::Isnil.new(el[4], el[8])
    end

    def term_head(t, a, b, el)
      Term::Head.new(el[4], el[8])
    end

    def term_tail(t, a, b, el)
      Term::Tail.new(el[4], el[8])
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

    def type_list(t, a, b, el)
      Type::List.new(el[2])
    end

    def type_base(t, a, b, el)
      Type::Base.new(t[a ... b])
    end

    def type_pair(t, a, b, el)
      Type::Product.new(el[0], el[4])
    end

    def type_sum(t, a, b, el)
      Type::Sum.new(el[0], el[4])
    end

    def type_tuple(t, a, b, el)
      types = [el[2]] + el[4].map(&:type)
      Type::Tuple.new(types)
    end

    def type_record(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:rt_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.type] }
      Type::Record.new(Hash[pairs])
    end

    def type_variant(t, a, b, el)
      pairs = [el[1]] + el[2].map(&:rt_pair)
      pairs = pairs.map { |pair| [pair.label.text, pair.type] }
      Type::Variant.new(Hash[pairs])
    end

  end
end
