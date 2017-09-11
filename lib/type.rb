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

  Top = Class.new do
    include Term::Atom

    def inspect
      'Top'
    end
  end.new

  Record = Struct.new(:members) do
    include Term::Atom

    def inspect
      pairs = members.map { |k, t| "#{k}: #{t.inspect}" }
      "{#{pairs * ', '}}"
    end
  end
end
