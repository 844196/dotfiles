#!/usr/bin/env bash
# UserPromptSubmit hook: 新しいユーザー入力ターンの開始時に、edit-reminders
# のフラグディレクトリを丸ごとクリアする。直後に git-snapshot (現時点で
# git status が削除として認識しているパス一覧) を保存し、Stop hook が
# ターン中に新規発生した削除を検出するための基準点にする。
#
# git status は --no-optional-locks 付きで実行する (.git/index.lock の残置
# 回避、cf. files/dot_local/share/zsh/exact_functions/exact_Prompts/prompt_zen_setup)。

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[ -z "$cwd" ] && cwd="$(pwd)"

[ -z "$session_id" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
rm -rf "$state_dir"

if git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null; then
  mkdir -p "$state_dir"
  git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null \
    | grep -E '^.D|^D.|^R' \
    | sed -E 's/^.{3}//; s/ -> .*$//' \
    | sort -u \
    > "$state_dir/git-snapshot" || true
fi
