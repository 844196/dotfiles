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
#   ターン開始時の snap-files (CWD git 作業ツリー配下、.gitignore 除外、
#   <hash>\t<path> 一覧) と現状の同形式一覧を path key でマージし、
#     ADDED    - new にしか居ない path  → 新規発生
#     MODIFIED - 両方に居て hash 違う   → 内容変更
#     REMOVED  - old にしか居ない path  → 削除 / リネーム旧パス
#   に分類する。
# tracked/untracked を区別せず純粋にファイル内容 hash のみで判定するので、
# git add や git commit のような index 移動は snap に変化を生じさせない
# (= 内容が変わらない作業ではフックが発火しない)。
# Edit/Write/NotebookEdit/サブエージェント/MCP/Bash 経由 (rm/mv/cp/redirect 等) を
# 経路を問わず一律に検知する。
#
# 既知の盲点:
#   - .gitignore 配下のファイル
#   - git リポジトリ外の CWD では一切検知しない
#   - mode 変更 (実行ビット等) は内容不変なら検知しない

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[ -z "$cwd" ] && cwd="$(pwd)"

[ -z "$session_id" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
[ -d "$state_dir" ] || exit 0
[ -f "$state_dir/blocked" ] && exit 0

# CWD ではなくリポジトリルートを基準にする
repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" || exit 0

# snap 取得時と異なるリポジトリならスキップ
if [ -f "$state_dir/repo_root" ]; then
  snap_repo_root="$(cat "$state_dir/repo_root")"
  [ "$snap_repo_root" != "$repo_root" ] && exit 0
fi

has_md=0
has_impl=0
has_deleted=0

classify_path() {
  case "$1" in
    *.md) has_md=1 ;;
    *)    has_impl=1 ;;
  esac
}

new_paths_file="$state_dir/.new-paths"
new_hashes_file="$state_dir/.new-hashes"
new_snap_file="$state_dir/.new-snap"

git -C "$repo_root" --no-optional-locks ls-files --cached --others --exclude-standard 2>/dev/null \
  | while IFS= read -r p; do
      if [ -e "$repo_root/$p" ]; then printf '%s\n' "$p"; fi
    done > "$new_paths_file"

if [ -s "$new_paths_file" ]; then
  git -C "$repo_root" hash-object --stdin-paths < "$new_paths_file" \
    > "$new_hashes_file" 2>/dev/null || true
  paste "$new_hashes_file" "$new_paths_file" | LC_ALL=C sort -k2 > "$new_snap_file"
else
  : > "$new_snap_file"
fi

if [ -f "$state_dir/snap-files" ]; then
  while IFS=$'\t' read -r kind path; do
    [ -z "$kind" ] && continue
    case "$kind" in
      ADDED|MODIFIED) classify_path "$path" ;;
      REMOVED) has_deleted=1; classify_path "$path" ;;
    esac
  done < <(awk -F'\t' -v OFS='\t' \
              -v old_file="$state_dir/snap-files" \
              -v new_file="$new_snap_file" '
              FILENAME == old_file { old[$2]=$1; next }
              FILENAME == new_file {
                if ($2 in old) {
                  if (old[$2] != $1) print "MODIFIED", $2
                  delete old[$2]
                } else {
                  print "ADDED", $2
                }
              }
              END {
                for (p in old) print "REMOVED", p
              }
            ' "$state_dir/snap-files" "$new_snap_file")
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
- 勝手なセクション追加: 指示にないセクション (e.g.「結論」「まとめ」) を追加していないか

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
