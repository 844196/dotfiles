#!/usr/bin/env bash

set -euo pipefail

if ! chezmoi="$(command -v chezmoi)"; then
  mkdir -p ~/.local/bin
  if command -v curl &>/dev/null; then
    sh -c "$(curl -fsSL get.chezmoi.io)" -- -b ~/.local/bin -t v2.69.4
  elif command -v wget &>/dev/null; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b ~/.local/bin -t v2.69.4
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  chezmoi=~/.local/bin/chezmoi
fi

dotfiles="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

if [[ -z "${GITHUB_TOKEN:-}" && -f "${GITHUB_TOKEN_FILE:-}" ]]; then
  : ${GITHUB_TOKEN:=$(<"$GITHUB_TOKEN_FILE")}
fi

GITHUB_TOKEN="$GITHUB_TOKEN" "$chezmoi" init --apply --source="$dotfiles"
