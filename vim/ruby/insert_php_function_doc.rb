main = -> (vim) do
  require File::expand_path('../ParsedMethod', __FILE__)

  lines = vim
    .tap {|v| v.command('execute "normal! ^"') }
    .evaluate('getline(search("function", "cnW"), search(")", "cnW"))')
    .join

  doc = ParsedMethod::from(lines).to_doc.split("\n")

  unless lines.length.zero?
    vim.evaluate("append(line('.') - 1, #{doc.inspect})")
  end
end

main[Vim] if $0 === 'vim-ruby'
