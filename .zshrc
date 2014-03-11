# 補完
autoload -U compinit
compinit

# 言語
export LANG=ja_JP.UTF-8

# もしかして機能
setopt correct

PROMPT="(๑•﹏•) %/%% $ "
SPROMPT="(๑•﹏•) < もしかして %r ? [n, y, a, e]:"

# /usr/binより/usr/local/binを優先
export PATH=/usr/local/bin:$PATH
