#!/bin/bash

gh="$(~/.local/bin/aqua which gh)"

exec "$gh" completion -s zsh > ~/.local/share/zsh/vendor-completions/_gh
