#!/usr/bin/env zsh

~/.local/bin/mise completion zsh > ~/.zsh/vendor-completions/_mise

~/.local/bin/mise install
~/.local/bin/mise upgrade
