class Parameter
  def initialize(name, type, variadic, nullable)
    @name = name
    @type = type
    @variadic = variadic
    @nullable = nullable
  end

  attr_reader :name

  def type
    @type \
      + @nullable.tap {|n| break n ? '|null' : '' } \
      + @variadic.tap {|v| break v ? '[]' : '' }
  end
end
