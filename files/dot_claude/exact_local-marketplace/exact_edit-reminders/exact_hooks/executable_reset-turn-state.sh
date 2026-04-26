#!/usr/bin/env bash
# UserPromptSubmit hook: 新しいユーザー入力ターンの開始時に、CWD の git 作業ツリー
# 配下のファイル内容のスナップショットを取る。Stop hook がこれを現状と比較して
# ターン中に発生した内容変更を検出する。
#
# スナップショット内容:
#   snap-files - <hash>\t<path> の一覧 (path 列で sort 済み)。
#                path は ls-files --cached --others --exclude-standard で列挙
#                (.gitignore 配下は除外、削除済み tracked は除外)。
#                hash は git hash-object --stdin-paths でファイル内容をハッシュ化。
#                tracked/untracked を区別せず純粋にファイル内容 hash のみで差分判定
#                するため、git add や git commit のような index 移動は snap に変化を
#                生じさせない (= 内容が変わらない作業ではフックが発火しない)。
#
# git status は --no-optional-locks 付きで実行する (.git/index.lock の残置回避、
# cf. files/dot_local/share/zsh/exact_functions/exact_Prompts/prompt_zen_setup)。

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[ -z "$cwd" ] && cwd="$(pwd)"

[ -z "$session_id" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
rm -rf "$state_dir"

git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null || exit 0

mkdir -p "$state_dir"

paths_file="$state_dir/.paths"
hashes_file="$state_dir/.hashes"

# 削除済み tracked (index には居るが work tree に無い) は hash-object に渡せないので
# [ -e ] で work tree 存在を確認しながらフィルタする。
git -C "$cwd" --no-optional-locks ls-files --cached --others --exclude-standard 2>/dev/null \
  | while IFS= read -r p; do
      if [ -e "$cwd/$p" ]; then printf '%s\n' "$p"; fi
    done > "$paths_file"

if [ -s "$paths_file" ]; then
  git -C "$cwd" hash-object --stdin-paths < "$paths_file" \
    > "$hashes_file" 2>/dev/null || true
  paste "$hashes_file" "$paths_file" | LC_ALL=C sort -k2 > "$state_dir/snap-files"
else
  : > "$state_dir/snap-files"
fi

rm -f "$paths_file" "$hashes_file"
