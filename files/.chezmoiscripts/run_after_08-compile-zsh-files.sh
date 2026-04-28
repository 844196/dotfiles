#!/usr/bin/env zsh

local files=(
  ~/.zsh/.{zshenv,zshrc}
  ~/.zsh/plugins/zsh-autosuggestions/**/*.zsh
)

local f
for f in $files; do
  echo "Compiling $f"
  zcompile -R -- "$f".zwc "$f"
done
