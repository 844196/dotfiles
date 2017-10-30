class String
  def width_on_term
    s = self.gsub(/\x1B\[(?:[0-9]{1,2}(?:;[0-9]{1,3})?)?[m|K]/, '')
    s.length + s.chars.reject {|c| c.match(/[\uff66-\uff9f]/) || c.ascii_only? }.length
  end
end

class Table
  def initialize(rows, opts = {})
    @rows = rows
    @opts = {:sep => ' '}.merge(opts)
  end

  def render
    @rows.map do |row|
      row
        .map
        .with_index {|col,idx| "#{col}#{' ' * (width_map[idx] - col.to_s.width_on_term)}" }
        .join(@opts[:sep])
        .rstrip
    end
  end

  private

  def width_map
    @width_map ||= @rows.inject(Hash.new(0)) do |acc,row|
      row.each_with_index do |col,idx|
        wot = col.to_s.width_on_term
        acc[idx] = wot if wot > acc[idx]
      end
      acc
    end
  end
end

class Array
  def tablize(opts = {})
    Table.new(self, opts).render
  end
end
