lines = Vim::Buffer.current
called_ln = lines.line_number
function = Function.new

called_ln.upto(lines.count) do |ln|
  line = lines[ln]

  if ln === called_ln && m = line.match(Function::REGEX_BODY)
    function.name = m['function_name']
    function.indent = m['indent']
  end

  lines[ln].scan(Function::REGEX_PARAM) do |arg|
    function.params << Parameter.new(*arg)
  end

  break if /\)/ =~ line
end

Vim.command("call append(line('.') - 1, #{VimList.new(function.doc).to_vim_list})")
