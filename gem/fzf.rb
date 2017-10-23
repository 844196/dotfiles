class Array
  def fzf
    selected = IO.popen('fzf', 'r+').tap do |io|
      io.puts(self)
      io.close_write
      break io.readlines.map(&:chomp)
    end
    block_given? ? yield(selected) : selected
  end
end
