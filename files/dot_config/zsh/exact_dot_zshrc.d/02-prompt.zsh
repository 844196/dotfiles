setopt transient_rprompt

# see: https://superuser.com/questions/1391414/why-am-i-having-a-sign-between-the-lines-in-integrated-terminal-in-vs-code
if [ "$TERM_PROGRAM" = "vscode" ]; then
  unsetopt PROMPT_SP
fi
