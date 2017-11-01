class Spinner
  def initialize(message, symbols, fps = 10)
    @message = Enumerator.new do |e|
      syms = symbols.to_enum
      loop do
        begin
          e << message % syms.next
        rescue StopIteration
          syms.rewind
        end
      end
    end
    @delay = 1.0 / fps
  end

  def until
    spinner = Thread.new do
      loop do
        print @message.next
        sleep @delay
        print "\r"
      end
    end

    yield.tap do
      spinner.kill
      print "\x1b[2K\r"
    end
  end

  class << self
    def until(message, symbols, &block)
      self.new(message, symbols).until(&block)
    end
  end
end
