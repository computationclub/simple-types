module Term
  module Atom
    def atomic
      inspect
    end
  end

  module Compound
    def atomic
      "(#{inspect})"
    end
  end

  Var = Struct.new(:name) do
    include Atom

    def inspect
      name
    end
  end

  Abs = Struct.new(:param, :type, :body) do
    include Compound

    def inspect
      "λ#{param}:#{type.inspect}. #{body.inspect}"
    end
  end

  Application = Struct.new(:left, :right) do
    include Compound

    def inspect
      func = left.is_a?(Application) ? left.inspect : left.atomic
      "#{func} #{right.atomic}"
    end
  end

  True = Class.new do
    include Atom

    def inspect
      'true'
    end
  end.new

  False = Class.new do
    include Atom

    def inspect
      'false'
    end
  end.new

  If = Struct.new(:condition, :consequent, :alternate) do
    include Compound

    def inspect
      "if #{condition.atomic} then #{consequent.atomic} else #{alternate.atomic}"
    end
  end

  Zero = Class.new do
    include Atom

    def inspect
      '0'
    end
  end.new

  Succ = Struct.new(:arg) do
    include Compound

    def inspect
      "succ #{arg.atomic}"
    end
  end

  Pred = Struct.new(:arg) do
    include Compound

    def inspect
      "pred #{arg.atomic}"
    end
  end

  Iszero = Struct.new(:arg) do
    include Compound

    def inspect
      "iszero #{arg.atomic}"
    end
  end

  Unit = Class.new do
    include Atom

    def inspect
      'unit'
    end
  end.new

  Sequence = Struct.new(:first, :last) do
    include Compound

    def inspect
      "#{first.inspect} ; #{last.inspect}"
    end
  end

  Ascribe = Struct.new(:term, :type) do
    include Compound

    def inspect
      "#{term.atomic} as #{type.inspect}"
    end
  end

  Let = Struct.new(:param, :arg, :body) do
    include Compound

    def inspect
      "let #{param} = #{arg.atomic} in #{body.atomic}"
    end
  end

  Project = Struct.new(:term, :field) do
    include Compound

    def inspect
      base = term.is_a?(Project) ? term.inspect : term.atomic
      "#{base}.#{field}"
    end
  end

  Pair = Struct.new(:left, :right) do
    include Atom

    def inspect
      "{#{left.atomic} | #{right.atomic}}"
    end
  end

  Tuple = Struct.new(:members) do
    include Atom

    def inspect
      "{#{members.map(&:inspect) * ', '}}"
    end
  end

  Record = Struct.new(:members) do
    include Atom

    def inspect
      pairs = members.map { |k, t| "#{k} = #{t.inspect}" }
      "{#{pairs * ', '}}"
    end
  end

  Inl = Struct.new(:term, :type) do
    include Atom

    def inspect
      "inl #{term.atomic} as #{type.atomic}"
    end
  end

  Inr = Struct.new(:term, :type) do
    include Atom

    def inspect
      "inr #{term.atomic} as #{type.atomic}"
    end
  end

  SumCase = Struct.new(:term, :left, :right) do
    include Compound

    def inspect
      "case #{term.atomic} of inl #{left.inspect} | inr #{right.inspect}"
    end
  end

  VarCase = Struct.new(:term, :clauses) do
    include Atom

    def inspect
      cs = clauses.map do |label, clause|
        "<#{label}=#{clause.param}> ⇒ #{clause.body.atomic}"
      end
      "case #{term.atomic} of #{cs * ' | '}"
    end
  end

  CaseClause = Struct.new(:param, :body) do
    include Atom

    def inspect
      "#{param} ⇒ #{body.atomic}"
    end
  end

  Tagged = Struct.new(:label, :term, :type) do
    include Atom

    def inspect
      "<#{label}=#{term.inspect}> as #{type.atomic}"
    end
  end
end
