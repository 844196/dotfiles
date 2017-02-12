doc_generator = -> (lines) do
  regex = {
    :body => /\A(\s*).*function\s+([^(\s]+)/,
    :arg => /(?:.*\(|,\s*)?([^\$\s,\.]+)?\s*(\.{3})?(\$[^\),\s]+)/
  }

  func = Hash.new {|h,k| h[k] = [] }
  arg = -> (type, is_variable_length, name) do
    if is_variable_length
      t = type ? "#{type}[]" : 'array'
    else
      t = type || 'mixed'
    end
    {:type => t, :name => name}
  end

  lines.each_with_index do |line, idx|
    if idx.zero?
      _, func[:indent], func[:name] = *line.match(regex[:body])
    end

    line.scan(regex[:arg]) do |matched|
      func[:args] << arg[*matched]
    end
  end

  type_padding = func[:args].map {|a| a[:type].length }.max
  result = [
    '/**',
    " * #{func[:name]}",
    ' *',
      * func[:args].map {|a| " * @param #{a[:type].ljust(type_padding)} #{a[:name]}" },
    ' */',
  ]

  result.map {|l| func[:indent] + l }
end

main = -> (vim) do
  lines = vim
    .tap {|v| v.command('execute "normal! ^"') }
    .evaluate('getline(search("function", "cnW"), search(")", "cnW"))')

  unless lines.length.zero?
    vim.evaluate("append(line('.') - 1, #{doc_generator[lines].inspect})")
  end
end

main[Vim] if $0 === 'vim-ruby'
