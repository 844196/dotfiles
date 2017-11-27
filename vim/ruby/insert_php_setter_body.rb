main = -> (vim) do
  require File::expand_path('~/dotfiles/gem/PHParser/method/ParsedMethod')
  require File::expand_path('~/dotfiles/gem/PHParser/template/SetterBodyTemplate')

  params = vim::evaluate('s:params')

  method = ParsedMethod::from(params['lines'].join)
  template = SetterBodyTemplate.new(params['indent'])

  vim::command("let s:result = #{template.render(method).split("\n").inspect}")
end

main[Vim] if $0 === 'vim-ruby'
