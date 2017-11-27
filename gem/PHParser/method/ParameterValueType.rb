class ParameterValueType
  def initialize(type, default, variadic)
    @type = type
    @default = default
    @variadic = variadic
  end

  attr_reader :type, :default

  def variadic?
    @variadic
  end

  def to_s
    (@type.include?(@default) ? @type.to_s : "#{@type.to_s}|#{@default.to_s}").tap do |s|
      break @variadic ? s.include?('|') ? "(#{s})[]" : "#{s}[]" : s
    end
  end
end
