class ParameterCollection
  include Enumerable

  def initialize
    @collection = []
  end

  attr_reader :collection

  def <<(parameter)
    @collection << parameter
  end

  def type_padding
    @collection.map {|p| p.type.length }.max
  end

  def each
    @collection.each {|parameter| yield(parameter) }
  end
end
