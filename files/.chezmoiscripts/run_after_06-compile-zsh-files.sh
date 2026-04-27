#!/usr/bin/env zsh

local files=(
  ~/.zsh/.{zshenv,zshrc}
  ~/.zsh/plugins/zsh-autosuggestions/**/*.zsh
  ~/.zsh/plugins/fast-syntax-highlighting/**/*.zsh
  ~/.zsh/plugins/fast-syntax-highlighting/{fast-highlight,fast-string-highlight,fast-theme}
)

local f
for f in $files; do
  echo "Compiling $f"
  zcompile -R -- "$f".zwc "$f"
done
