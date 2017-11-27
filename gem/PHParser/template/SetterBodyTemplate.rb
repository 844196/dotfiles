class SetterBodyTemplate
  def initialize(indent)
    @indent = indent
  end

  def render(method)
    method
      .params
      .map {|p| "$this->#{p.name} = $#{p.name};" }
      .map {|l| "#{@indent}#{l}" }
      .join("\n")
  end
end
