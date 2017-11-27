class DocTemplate
  def initialize(indent)
    @indent = indent
  end

  def render(method)
    params = method
      .params
      .map {|p| [p.type.to_s, p.name] }
      .tap {|pair| p = pair.transpose.fetch(0, []).map(&:length).max; break pair.map {|_| _ << p } }
      .map {|t,n,p| " * @param #{t.ljust(p)} $#{n}" }

    return_value_type = (method.return_value_type.void? || method.constructor?) \
      ? [] \
      : [" * @return #{method.return_value_type.to_s}"]

    doc = [
      '/**',
        * params,
        * return_value_type,
      ' */',
    ]

    doc.map {|l| "#{@indent}#{l}" }.join("\n")
  end
end
