require File::expand_path('../../ValueType', __FILE__)
require File::expand_path('../Parameter', __FILE__)

class ParsedMethod
  REGEX = /
    \A
    \s*
    (?:(?:abstract|final)\s+)?
    (?:(?:public|protected|private)\s+)?
    (?:static\s+)?
    function\s+
    (?<name>[^\s\(]+)
    \((?<param_list>.+)?\)
    (?:\s*:\s*(?<return_value_type>[\?\\\w]+))?
  /xm

  def initialize(name, params, return_value_type)
    @name = name
    @params = params
    @return_value_type = return_value_type
  end

  attr_reader :name, :params, :return_value_type

  def constructor?
    @name == '__construct'
  end

  def self.from(str)
    matched = str.match(self::REGEX)

    params = matched[:param_list]
      .to_s
      .scan(Parameter::REGEX)
      .map {|m| Parameter::from(m.join(' ')) }

    self.new(
      matched[:name],
      params,
      ValueType::of(matched[:return_value_type] || 'mixed')
    )
  end
end
