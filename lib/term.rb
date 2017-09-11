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

  Project = Struct.new(:object, :field) do
    include Atom

    def inspect
      "#{object.atomic}.#{field}"
    end
  end

  Record = Struct.new(:members) do
    include Atom

    def inspect
      pairs = members.map { |k, t| "#{k} = #{t.atomic}" }
      "{#{pairs * ', '}}"
    end
  end
end
