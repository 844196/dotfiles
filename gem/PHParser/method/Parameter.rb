require File::expand_path('../../ValueType', __FILE__)
require File::expand_path('../ParameterValueType', __FILE__)

class Parameter
  REGEX = /
    (?<value_type>[\?\\\w]+)?
    \s*
    (?<dots>\.{3})?
    \s*
    (?<name>\$\w+)
    \s*
    (?<equal>=\s*(?<default_value>null|array\(|\[|[\d\.]+|['"]|.)?)?
  /xm

  def initialize(name, type)
    @name = name
    @type = type
  end

  attr_reader :name, :type

  def self.from(src)
    matched = src.match(self::REGEX)

    default_value_type = case matched[:default_value]
    when NilClass  then nil
    when 'null'    then ValueType::of('null')
    when '['       then ValueType::of('array')
    when 'array('  then ValueType::of('array')
    when /\A['"]/  then ValueType::of('string')
    when /\A\d+\z/ then ValueType::of('int')
    when /\./      then ValueType::of('float')
    else                ValueType::of('mixed')
    end

    self.new(
      matched[:name][1..-1],
      ParameterValueType.new(
        ValueType::of(matched[:value_type] || 'mixed'),
        default_value_type,
        matched[:dots].nil?.!
      )
    )
  end
end
