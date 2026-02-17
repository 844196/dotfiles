#!/usr/bin/env zsh

~/.local/bin/mise completion zsh > ~/.local/share/zsh/vendor-completions/_mise

~/.local/bin/mise install
~/.local/bin/mise upgrade
