class ValueType
  def initialize(name, nullable)
    @name = name
    @nullable = nullable
  end

  attr_reader :name

  def nullable?
    @nullable
  end

  def method_missing(called_name)
    @name == called_name.to_s[0..-2]
  end

  def to_s
    nullable? ? "#{@name}|null" : @name
  end

  def include?(other)
    to_s.include?(other.to_s)
  end

  def self.of(str)
    nullable = str[0] == '?'
    self.new(nullable ? str[1..-1] : str, nullable)
  end
end
