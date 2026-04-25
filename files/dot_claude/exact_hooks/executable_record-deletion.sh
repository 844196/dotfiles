#!/usr/bin/env bash
# PostToolUse:Bash hook: 実行された Bash コマンドが rm / git rm を含めば
# flag-deleted を立てる。command 内の単語境界で `rm` または `git rm` を検出する。
# 厳密な path 抽出はしない (削除があった事実だけを Stop hook に伝える)。
# 削除パスの厳密検知が必要なケースは edit-reminders-on-stop.sh が
# git status diff で補完する。

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
command="$(jq -r '.tool_input.command // empty' <<<"$input")"

[ -z "$session_id" ] && exit 0
[ -z "$command" ] && exit 0

# 単語境界で rm / git rm を検出: 行頭/空白/;/&/||/( の直後
if echo "$command" | grep -qE '(^|[[:space:];&|()])(rm|git[[:space:]]+rm)([[:space:];&|()]|$)'; then
  state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
  mkdir -p "$state_dir"
  touch "$state_dir/deleted"
fi
