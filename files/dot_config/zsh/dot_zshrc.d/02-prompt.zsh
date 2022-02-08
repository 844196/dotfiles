setopt transient_rprompt

# see: https://superuser.com/questions/1391414/why-am-i-having-a-sign-between-the-lines-in-integrated-terminal-in-vs-code
if [ "$TERM_PROGRAM" = "vscode" ]; then
  unsetopt PROMPT_SP
fi

autoload -Uz colors && colors

PROMPT="
%{$fg[blue]%}%n@%m:%~%{$reset_color%}
%{%(?.$fg_bold[black].$fg[red])%}%#%{$reset_color%} "
