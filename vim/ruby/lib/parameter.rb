class Parameter
  def initialize(type, variable)
    @type = type || 'mixed'
    @variable = variable
  end

  attr_accessor :type, :variable
end
