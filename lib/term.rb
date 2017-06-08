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

  Pair = Struct.new(:first, :second) do
    include Atom

    def inspect
      "{#{first.atomic}, #{second.atomic}}"
    end
  end
end
