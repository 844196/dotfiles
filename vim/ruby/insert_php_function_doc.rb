main = Proc.new do |lines|
  regex_body = /
    ^(?<indent>\s*)
    (?:abstract\s*)?
    (?:public|private|protected)?\s*
    (?:static\s*)?
    function\s*
    (?<name>[^(]+)\(
  /x
  regex_arg = /
    (?:.*\(|,\s*)?
    (?<type>[^\$\s]+)?\s*
    (?<name>\$[^\),]+)
  /x

  function = {:indent => '', :name => '', :args => []}
  lines.each_with_object(function).with_index do |(line, obj), idx|
    if idx.zero?
      _, function[:indent], function[:name] = *line.match(regex_body)
    end

    line.scan(regex_arg) do |arg|
      function[:args] << {:type => arg[0] || 'mixed', :name => arg[1]}
    end
  end

  type_padding = function[:args].map {|a| a[:type].length }.max
  result = [
    '/**',
    " * #{function[:name]}",
    ' *',
      * function[:args].map {|a| " * @param #{a[:type].ljust(type_padding)} #{a[:name]}" },
    ' * @return void',
    ' */',
  ]

  Vim.evaluate("append(line('.') - 1, #{result.map {|l| function[:indent] + l }.inspect})")
end

Vim
  .tap {|vim| vim.command('execute "normal! ^"') }
  .evaluate('getline(search("function", "nW"), search(")", "nW"))')
  .tap {|lines| main.call(lines) unless lines.length.zero? }
