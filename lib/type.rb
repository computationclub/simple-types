module Type
  Function = Struct.new(:from, :to) do
    include Term::Compound

    def inspect
      right = to.is_a?(Function) ? to.inspect : to.atomic
      "#{from.atomic} → #{right}"
    end
  end

  Boolean = Class.new do
    include Term::Atom

    def inspect
      'Bool'
    end
  end.new

  Natural = Class.new do
    include Term::Atom

    def inspect
      'Nat'
    end
  end.new

  Base = Struct.new(:name) do
    include Term::Atom

    def inspect
      name
    end
  end

  Unit = Class.new do
    include Term::Atom

    def inspect
      'Unit'
    end
  end.new

  Top = Class.new do
    include Term::Atom

    def inspect
      'Top'
    end
  end.new

  Product = Struct.new(:left, :right) do
    include Term::Compound

    def inspect
      r = right.is_a?(Product) ? right.inspect : right.atomic
      "#{left.atomic} × #{r}"
    end
  end

  Sum = Struct.new(:left, :right) do
    include Term::Compound

    def inspect
      r = right.is_a?(Sum) ? right.inspect : right.atomic
      "#{left.atomic} + #{r}"
    end
  end

  Tuple = Struct.new(:members) do
    include Term::Atom

    def inspect
      "{#{members.map(&:inspect) * ', '}}"
    end
  end

  Record = Struct.new(:members) do
    include Term::Atom

    def inspect
      pairs = members.map { |k, t| "#{k}: #{t.inspect}" }
      "{#{pairs * ', '}}"
    end
  end

  Variant = Struct.new(:clauses) do
    include Term::Atom

    def inspect
      pairs = clauses.map { |k, t| "#{k}: #{t.inspect}" }
      "<#{pairs * ', '}>"
    end
  end

  List = Struct.new(:type) do
    include Term::Compound

    def inspect
      "List #{type.atomic}"
    end
  end

  Ref = Struct.new(:type) do
    include Term::Compound

    def inspect
      "Ref #{type.atomic}"
    end
  end
end
