class VimList
  include Enumerable

  def initialize(list)
    @list = list
  end

  def to_vim_list
    @list
      .map {|item| "\"#{item.gsub(/\\/, '\\\\\\')}\"" }
      .tap {|item| break ['[', *item.join(','), ']'] }
      .join
  end

  def each
    @list.each {|item| yield(item) }
  end
end
