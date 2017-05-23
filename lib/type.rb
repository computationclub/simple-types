module Type
  Boolean = Class.new do
    def inspect
      "Bool"
    end
  end.new

  Function = Struct.new(:from, :to) do
    def inspect
      "#{from.inspect} → #{to.inspect}"
    end
  end
end

