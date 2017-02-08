class Function
  REGEX_BODY = /
    ^(?<indent>\s*)
    (?:abstract\s*)?
    (?:public|private|protected)?\s*
    (?:static\s*)?
    function\s*
    (?<function_name>[^(]+)\(
  /x

  REGEX_PARAM = /
    (?:.*\(|,\s*)?
    (?<type>[^\$\s]+)?\s*
    (?<variable_name>\$[^=,\s\)]+)
  /x

  def initialize
    @name = '';
    @indent = '';
    @params = ParameterCollection.new
  end

  attr_accessor :name, :indent
  attr_reader :params

  def doc
    [
      '/**',
      " * #{@name}",
      ' *',
        * @params.map {|p| " * @param #{p.type.ljust(@params.type_padding)} #{p.variable}" },
      ' * @return void',
      ' */'
    ].map {|l| @indent + l }
  end
end
