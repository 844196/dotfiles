class TermColor
  COLOR_MAP = {
    :black => 0,
    :red => 1,
    :green => 2,
    :yellow => 3,
    :blue => 4,
    :magenta => 5,
    :cyan => 6,
    :white => 7,
    :light_black => 8,
    :light_red => 9,
    :light_green => 10,
    :light_yellow => 11,
    :light_blue => 12,
    :light_magenta => 13,
    :light_cyan => 14,
    :light_white => 15,
  }

  def initialize(color)
    @color = color
  end

  def none?
    @color.nil?
  end

  def truecolor?
    @color =~ /(?:\h\h){3}/
  end

  def format_string
    none? ? '%s' : "\x1b[#{self.class::TYPE};#{ansi_color}m%s\x1b[0m"
  end

  private

  def ansi_color
    return "05;#{COLOR_MAP[@color]}" unless truecolor?
    @color
      .scan(/\h\h/)
      .map {|x| (x + x)[0, 2].hex }
      .tap {|m| break "2;#{m * ';'}" }
  end
end

class TermFgColor < TermColor
  TYPE = 38
end

class TermBgColor < TermColor
  TYPE = 48
end

class ColorizedString
  def initialize(string, opts)
    @string = string

    fg, bg = case opts
    when Hash then [opts[:fg], opts[:bg]]
    else [opts, nil]
    end
    @fg, @bg = [TermFgColor.new(fg), TermBgColor.new(bg)]
  end

  def to_s
    @bg.format_string % (@fg.format_string % @string)
  end
end

class String
  def colorize(opts)
    ColorizedString.new(self, opts).to_s
  end
end
