#!/usr/bin/env zsh

local files=(
  ~/.config/zsh/.{zshenv,zshrc}
  ~/.local/share/zsh/plugins/zsh-autosuggestions/**/*.zsh
  ~/.local/share/zsh/plugins/fast-syntax-highlighting/**/*.zsh
  ~/.local/share/zsh/plugins/fast-syntax-highlighting/{fast-highlight,fast-string-highlight,fast-theme}
)

local f
for f in $files; do
  echo "Compiling $f"
  zcompile -R -- "$f".zwc "$f"
done
