require File::expand_path('../Parameter', __FILE__)

class ParameterCollection
  include Enumerable

  REGEX = /
    (?<nullable>\?)?
    (?<type>[\w]+)?
    \s*
    (?<dots>\.{3})?
    (?<name>\$\w+)
    \s*
    (?<defaultNull>=\s*null)?
    ,?
  /xm

  def initialize(params)
    @params = params
  end

  def each(&block)
    @params.each(&block)
  end

  def self.from(str)
    params = str.to_s.delete("\t\n").scan(self::REGEX).map do |nullable,type,dots,name,defaultNull|
      Parameter.new(name, type || 'mixed', dots.nil?.!, (nullable || defaultNull).nil?.!)
    end
    self.new(params)
  end
end
