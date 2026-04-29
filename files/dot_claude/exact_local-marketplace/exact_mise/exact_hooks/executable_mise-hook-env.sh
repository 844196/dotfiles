#!/usr/bin/env zsh
set -euo pipefail

payload=$(cat)

cwd="$(jq -r '.new_cwd // .cwd' <<< "$payload")"
if [[ "$cwd" == null ]]; then
  exit
fi

# hook-env には --cd があるが、mise 環境変数プラグインが --cd を考慮していないように見える
# 確実に動かすために実際にカレントディレクトリを移動させる
(
  cd "$cwd"
  mise hook-env --shell zsh --force >> "$CLAUDE_ENV_FILE"
)
