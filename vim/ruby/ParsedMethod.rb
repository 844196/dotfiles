require File::expand_path('../ParameterCollection', __FILE__)

class ParsedMethod
  REGEX = /
    ^
    (?<indent>\s+)?
    (?:(?:abstract|final)\s+)?
    (?:(?:public|protected|private)\s+)?
    (?:static\s+)?
    function\s+
    (?<methodName>[^\s\(]+)
    \((?<params>.+)?\)
    (?:\s*:\s*(?<returnType>\S+))?
  /xm

  def initialize(indent, name, params, returnType)
    @indent = indent
    @name = name
    @params = params
    @returnType = returnType
  end

  def constructor?
    @name == '__construct'
  end

  def description
    @name
      .delete('_')
      .gsub(/([A-Z])/) {|c| " #{c.downcase}" }
      .gsub(/\A(.)/) {|c| c.upcase }
  end

  def magicMethod?
    @name =~ /\A__/
  end

  def to_doc
    desc = magicMethod? ? [] : [" * #{description}"]
    typePadding = @params.map {|p| p.type.length }.max
    params = @params.map {|p| " * @param #{p.type.ljust(typePadding)} #{p.name}" }
    returnType = (constructor? || @returnType == 'void') ? [] : [" * @return #{@returnType}"]

    if (params.empty? && returnType.empty?)
      desc << ' *' if magicMethod?
    else
      desc << ' *' unless magicMethod?
    end

    generated = [
      '/**',
        * desc,
        * params,
        * returnType,
      ' */',
    ]

    generated.map {|line| "#{@indent}#{line}" }.join("\n")
  end

  def self.from(str)
    _, indent, name, params, returnType = *str.match(self::REGEX)
    self.new(indent, name, ParameterCollection::from(params), returnType || 'mixed')
  end
end
