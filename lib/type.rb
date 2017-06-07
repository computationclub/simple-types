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
end
