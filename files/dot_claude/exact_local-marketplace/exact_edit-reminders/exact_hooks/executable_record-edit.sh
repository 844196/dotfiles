#!/usr/bin/env bash
# PostToolUse:Edit|Write hook: 編集されたファイルパスの拡張子で md / impl を
# 振り分け、対応するフラグファイルを edit-reminders ディレクトリに置く。
# Stop hook (edit-reminders-on-stop.sh) がフラグの有無を見て reason を組む。

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
file_path="$(jq -r '.tool_input.file_path // empty' <<<"$input")"

[ -z "$session_id" ] && exit 0
[ -z "$file_path" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
mkdir -p "$state_dir"

case "$file_path" in
  *.md) touch "$state_dir/md" ;;
  *)    touch "$state_dir/impl" ;;
esac
