#!/usr/bin/env bash
# UserPromptSubmit hook: 新しいユーザー入力ターンの開始時に、CWD の git 作業ツリーの
# 状態をスナップショットする。Stop hook がこのスナップショットと現状を比較して
# ターン中に発生した変更を検出する。
#
# スナップショット内容:
#   snap-tracked   - git stash create で作成した commit-ish (tracked content の状態)
#                    dirty な状態なら stash commit、そうでなければ HEAD。
#   snap-untracked - ls-files --others --exclude-standard の <hash>\t<path> 一覧
#                    (.gitignore 配下は除外、各 path は git hash-object でハッシュ化、
#                     path 列で sort 済み)。hash は Stop 側で「既存 untracked ファイル
#                     への追記」を検知するために使う。
#
# git status は --no-optional-locks 付きで実行する (.git/index.lock の残置回避、
# cf. files/dot_local/share/zsh/exact_functions/exact_Prompts/prompt_zen_setup)。
# stash create はオブジェクトを .git/objects に書くが、unreachable なので
# git gc で回収される (実害は微小)。

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

snap=$(git -C "$cwd" --no-optional-locks stash create 2>/dev/null || true)
if [ -z "$snap" ]; then
  snap=$(git -C "$cwd" rev-parse HEAD 2>/dev/null || true)
fi
[ -n "$snap" ] && printf '%s\n' "$snap" > "$state_dir/snap-tracked"

git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard -z 2>/dev/null \
  | while IFS= read -r -d '' p; do
      h=$(git -C "$cwd" hash-object -- "$p" 2>/dev/null || echo MISSING)
      printf '%s\t%s\n' "$h" "$p"
    done | LC_ALL=C sort -k2 > "$state_dir/snap-untracked" || true
