#!/usr/bin/env zsh

~/.local/bin/mise completion zsh > ~/.local/share/zsh/vendor-completions/_mise

~/.local/bin/mise install
~/.local/bin/mise upgrade

~/.local/bin/mise plugin link --force gh ~/.local/share/mise-plugins/gh
