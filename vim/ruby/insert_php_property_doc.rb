indent, variable = Vim::Buffer.current.line.match(/\A(?<i>\s*)(?<v>.+)/).tap {|m| break [m['i'], m['v']]}

doc = [
  '/**',
  " * @var #{variable.tap {|v| break 'mixed' if v =~ /\A[a-z].+/ }}",
  ' */',
].map {|l| indent + l }

Vim::Buffer.current.line = "#{indent}private $#{variable.sub(/\A./, &:downcase)};"
Vim.command("call append(line('.') - 1, #{VimList.new(doc).to_vim_list})")
