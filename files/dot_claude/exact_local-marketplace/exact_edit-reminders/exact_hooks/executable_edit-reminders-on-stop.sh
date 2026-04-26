#!/usr/bin/env bash
# Stop hook: UserPromptSubmit 時のスナップショットと現状を比較し、ターン中に
# 発生した変更から編集の種別 (md / impl / 削除) を判定して、対応する reminder を
# decision:"block" + reason で注入する。
#
# Stop イベントでは hookSpecificOutput.additionalContext は無効で、エージェント
# にメッセージを届ける唯一の手段は decision:"block" + reason (公式仕様)。
# ただし block は「停止のブロック=強制継続」なので、毎ターン奪うと煩い。
# そこで blocked フラグで「ターン内で既にブロック済み」を記録し、二度目以降
# の Stop では発火しない。フラグの削除は新しい user 入力ターン開始時
# (UserPromptSubmit) に reset-turn-state.sh が行う。
#
# ルール:
#   [doc-consistency] — has_md があれば
#   [doc-followup]    — has_impl OR has_deleted があれば
# 両方該当する場合は reason 内に両セクションを並べ、block は 1 回。
#
# 検知の仕組み:
#   tracked   - git stash create のスナップショット同士を git diff --name-status -M で比較
#   untracked - <hash>\t<path> 形式の一覧 (ls-files + git hash-object) を path で
#               マージし、ADDED / MODIFIED / REMOVED に分類
# どちらも CWD の git 作業ツリー限定なので、CWD 外の変更は構造的に拾わない。
# Edit/Write/NotebookEdit/サブエージェント/MCP/Bash 経由 (rm/mv/cp/redirect 等) を
# 経路を問わず一律に検知する。
#
# 既知の盲点:
#   - .gitignore 配下のファイル (`.agents/` 等は意図的に除外)
#   - git リポジトリ外の CWD では一切検知しない

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[ -z "$cwd" ] && cwd="$(pwd)"

[ -z "$session_id" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
[ -d "$state_dir" ] || exit 0
[ -f "$state_dir/blocked" ] && exit 0

git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null || exit 0

has_md=0
has_impl=0
has_deleted=0

classify_path() {
  case "$1" in
    *.md) has_md=1 ;;
    *)    has_impl=1 ;;
  esac
}

new_snap=$(git -C "$cwd" --no-optional-locks stash create 2>/dev/null || true)
if [ -z "$new_snap" ]; then
  new_snap=$(git -C "$cwd" rev-parse HEAD 2>/dev/null || true)
fi
old_snap=""
[ -f "$state_dir/snap-tracked" ] && old_snap=$(cat "$state_dir/snap-tracked")

# git add で untracked から tracked に移ったパスを記録する。
# untracked-removed の判定で「rm 由来」と「git add 由来」を区別するため。
tracked_added_file="$state_dir/.tracked-added"
: > "$tracked_added_file"

if [ -n "$old_snap" ] && [ -n "$new_snap" ]; then
  while IFS=$'\t' read -r code path1 path2; do
    [ -z "$code" ] && continue
    case "$code" in
      A*)
        classify_path "$path1"
        printf '%s\n' "$path1" >> "$tracked_added_file"
        ;;
      M*|T*)
        classify_path "$path1"
        ;;
      D*)
        has_deleted=1
        classify_path "$path1"
        ;;
      R*|C*)
        has_deleted=1
        classify_path "$path1"
        classify_path "$path2"
        printf '%s\n' "$path2" >> "$tracked_added_file"
        ;;
    esac
  done < <(git -C "$cwd" diff "$old_snap" "$new_snap" --name-status -M 2>/dev/null || true)
fi

sort -u "$tracked_added_file" -o "$tracked_added_file" 2>/dev/null || :

new_untracked_file="$state_dir/.new-untracked"
git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard -z 2>/dev/null \
  | while IFS= read -r -d '' p; do
      h=$(git -C "$cwd" hash-object -- "$p" 2>/dev/null || echo MISSING)
      printf '%s\t%s\n' "$h" "$p"
    done | LC_ALL=C sort -k2 > "$new_untracked_file" || true

# old (snap-untracked) と new (new-untracked) を path key でマージし、
#   ADDED    - new にしか居ない path        → 新規 untracked
#   MODIFIED - 両方に居て hash が異なる     → 既存 untracked への内容変更
#   REMOVED  - old にしか居ない path        → 削除 (ただし git add 由来は除外)
# の 3 種に分類する。tracked-added (A / R-new / C-new) と一致する REMOVED は
# 「git add で tracked に昇格した」だけなので削除扱いしない。
if [ -f "$state_dir/snap-untracked" ]; then
  while IFS=$'\t' read -r kind path; do
    [ -z "$kind" ] && continue
    case "$kind" in
      ADDED|MODIFIED) classify_path "$path" ;;
      REMOVED) has_deleted=1; classify_path "$path" ;;
    esac
  done < <(awk -F'\t' -v OFS='\t' \
              -v old_file="$state_dir/snap-untracked" \
              -v added_file="$tracked_added_file" \
              -v new_file="$new_untracked_file" '
              FILENAME == old_file   { old[$2]=$1; next }
              FILENAME == added_file { added[$1]=1; next }
              FILENAME == new_file {
                if ($2 in old) {
                  if (old[$2] != $1) print "MODIFIED", $2
                  delete old[$2]
                } else {
                  print "ADDED", $2
                }
              }
              END {
                for (p in old) if (!(p in added)) print "REMOVED", p
              }
            ' "$state_dir/snap-untracked" "$tracked_added_file" "$new_untracked_file")
fi

reasons=()

if [ "$has_md" -eq 1 ]; then
  reasons+=("$(cat <<'EOF'
[doc-consistency] 今ターンで Markdown が編集された。

全編集完了後に確認:
- 内部矛盾・用語の揺れ・重複がないか
- 見出し階層 (h1/h2/h3) が論理的に正しいか
- 関連ドキュメント (相互参照先、同ディレクトリ内の関連ファイル) との整合性
- リソース名の明確化: 略称や代名詞が「後から読み返した時にどこの何を指すかわかる」か
- 断定表現の根拠: 「判明」「確定」等を使う場合、エビデンスが明示されているか
- 比較セクションの対称性: 比較対象間で記載項目が揃っているか

不要と判断したならその旨だけ表明して進めばよい。
EOF
)")
fi

if [ "$has_impl" -eq 1 ] || [ "$has_deleted" -eq 1 ]; then
  body="今ターンで実装ファイルの変更があった。

これらの変更を踏まえ、エージェント向けドキュメントが古くなっていないか確認すること:
- CLAUDE.md (プロジェクト概要、コマンド、ディレクトリ構成)
- .claude/rules/ (規約、ルール)
- docs/ (アーキテクチャ、設計判断)"

  if [ "$has_deleted" -eq 1 ]; then
    body="$body

※ ターン中にファイル削除を検知。削除済みのファイルへの参照・リンクがドキュメントに残っていないか併せて確認すること。"
  fi

  body="$body

不要と判断したならその旨だけ表明して進めばよい。"

  reasons+=("[doc-followup] $body")
fi

[ "${#reasons[@]}" -eq 0 ] && exit 0

reason=""
for r in "${reasons[@]}"; do
  if [ -z "$reason" ]; then
    reason="$r"
  else
    reason="$reason

$r"
  fi
done

touch "$state_dir/blocked"

jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
