module Term
  True = Class.new do
    def inspect
      "true"
    end
  end.new

  False = Class.new do
    def inspect
      "false"
    end
  end.new

  Var = Struct.new(:name) do
    def inspect
      name
    end
  end

  Abs = Struct.new(:param, :type, :body) do
    def inspect
      "(λ#{param}:#{type.inspect} #{body.inspect})"
    end
  end

  If = Struct.new(:condition, :consequent, :alternate) do
    def inspect
      "if #{condition.inspect} then #{consequent.inspect} else #{alternate.inspect}"
    end
  end

  Application = Struct.new(:left, :right) do
    def inspect
      "(#{left.inspect} #{right.inspect})"
    end
  end
end

