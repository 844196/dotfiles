main = -> (vim) do
  _, prefix, subject = vim
    .evaluate('expand("<cword>")')
    .split(/(\A[^a-zA-Z0-9])/)

  subject = _ if [prefix, subject].all?(&:nil?)
  return unless subject

  case subject
  when -> (w) { w.include?('_') }
    replacement = subject.gsub(/(?:^|_)(.)/) { $1.upcase }
  when -> (w) { w =~ /\A[A-Z]/ }
    replacement = subject.gsub(/\A(.)/) { $1.downcase }
  when -> (w) { w =~ /\A[^A-Z]+[A-Z]/ }
    replacement = subject
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  else
    return
  end

  vim
    .command("execute 'normal! ciw#{prefix}#{replacement}'")
end

main[Vim] if $0 === 'vim-ruby'
