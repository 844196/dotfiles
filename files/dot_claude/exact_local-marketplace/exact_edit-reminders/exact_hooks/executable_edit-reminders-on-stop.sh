#!/usr/bin/env bash
# Stop hook: ターン中に PostToolUse 系 hook が立てたフラグと、UserPromptSubmit
# 時点との git status diff から削除を検出し、編集の種別に応じた reminder を
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
#   [doc-consistency] — flag-md があれば
#   [doc-followup]    — flag-impl OR (flag-deleted OR git status diff で削除検出) があれば
# 両方該当する場合は reason 内に両セクションを並べ、block は 1 回。
#
# 検知の対象/対象外 (PostToolUse での記録に依存):
#   対象  : Edit, Write tool_use (= record-edit.sh)
#           Bash の rm / git rm 系コマンド (= record-deletion.sh)
#           UserPromptSubmit 後に新規発生した削除 (= git status diff、補完用)
#   対象外: NotebookEdit, サブエージェント (Agent) 内の編集, MCP server の編集,
#           Bash 経由の mv/cp/touch/sed -i/redirect 等 (削除以外のファイル操作)
# 設計判断: 削除はドキュメント参照を破る影響が大きいため、PostToolUse:Bash の
# パターンマッチで主に検知し、漏れは git status の snapshot-diff で補完する。

set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[ -z "$cwd" ] && cwd="$(pwd)"

[ -z "$session_id" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/$session_id"
[ -d "$state_dir" ] || exit 0
[ -f "$state_dir/blocked" ] && exit 0

has_md=0
has_impl=0
has_deleted=0
[ -f "$state_dir/md" ] && has_md=1
[ -f "$state_dir/impl" ] && has_impl=1
[ -f "$state_dir/deleted" ] && has_deleted=1

# git status diff で削除を補完検出 (PostToolUse:Bash の record-deletion.sh が
# 拾えなかったケース、例: Bash 以外で発生した削除や複雑な削除コマンド)。
# --no-optional-locks で .git/index.lock の残置を回避。
if [ "$has_deleted" -eq 0 ] && [ -f "$state_dir/git-snapshot" ] \
  && git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null; then
  current_deletions="$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null \
    | grep -E '^.D|^D.|^R' \
    | sed -E 's/^.{3}//; s/ -> .*$//' \
    | sort -u || true)"
  new_deletions="$(comm -23 <(echo "$current_deletions") "$state_dir/git-snapshot" 2>/dev/null || true)"
  [ -n "$new_deletions" ] && has_deleted=1
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
