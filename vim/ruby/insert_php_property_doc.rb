_, indent, variable = *Vim::Buffer.current.line.match(/\A(?<i>\s*)(?<v>.+)/)

result = [
  '/**',
  " * @var #{variable.tap {|v| break 'mixed' if v =~ /\A[a-z].+/ }}",
  ' */',
]

Vim
  .tap {|vim| vim.command("call append(line('.') - 1, #{result.map {|l| indent + l }.inspect})") }
  .tap {|vim| vim::Buffer.current.line = "#{indent}private $#{variable.sub(/\A./, &:downcase)};" }
