module Term
  True = Object.new
  False = Object.new
  Var = Struct.new(:name)
  Abs = Struct.new(:param, :type, :body)
  If = Struct.new(:condition, :consequent, :alternate)
  Application = Struct.new(:left, :right)
end

