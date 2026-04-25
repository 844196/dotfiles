#!/usr/bin/env bash
# Stop hook: ターン中に実装変更 (CLAUDE.md / .claude/rules/ / docs/ 以外への Edit/Write)
# があれば、エージェント向けドキュメントの追従確認を促す。
#
# 規範本体: 「実装変更後、CLAUDE.md / .claude/rules/ / docs/ が古くなっていないか確認する」
# 旧来は ~/.claude/rules/agent-context-docs.md (常時ロード) で示していたが、
# 常時ロードでは忘却・省略されるため、Stop hook での強制注入に置き換える。

set -euo pipefail

input="$(cat)"
transcript_path="$(jq -r '.transcript_path // empty' <<<"$input")"

[ -z "$transcript_path" ] && exit 0
[ ! -f "$transcript_path" ] && exit 0

# 最後の user メッセージ以降を「今ターン」とみなす。
# transcript は JSONL で 1 行 1 メッセージ。
last_user_line="$(grep -n '"type":"user"' "$transcript_path" | tail -1 | cut -d: -f1)"
[ -z "$last_user_line" ] && exit 0

# 今ターンの assistant メッセージから Edit/Write の file_path を抽出
edited_files="$(tail -n +"$last_user_line" "$transcript_path" \
  | jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | select(.name == "Edit" or .name == "Write") | .input.file_path' 2>/dev/null \
  | sort -u)"

[ -z "$edited_files" ] && exit 0

# ドキュメント自身の編集は除外:
#   - 任意の CLAUDE.md
#   - .claude/rules/ 配下の .md
#   - docs/ 配下の .md (一般ルール: パスに /docs/ を含む .md)
implementation_changes="$(echo "$edited_files" \
  | grep -vE '(^|/)CLAUDE\.md$' \
  | grep -vE '/\.claude/rules/.*\.md$' \
  | grep -vE '/docs/.*\.md$' \
  || true)"

[ -z "$implementation_changes" ] && exit 0

file_list="$(echo "$implementation_changes" | sed 's/^/- /')"

context="$(cat <<EOF
今ターンで以下のファイルに変更があった:

$file_list

これらの変更を踏まえ、エージェント向けドキュメントが古くなっていないか確認すること:
- CLAUDE.md (プロジェクト概要、コマンド、ディレクトリ構成)
- .claude/rules/ (規約、ルール)
- docs/ (アーキテクチャ、設計判断)

配置の原則:
- 毎回必要 → CLAUDE.md
- 自動ロードしたい (常時 or 条件付き) → .claude/rules/
- rule 本体に書くにはサイズが大きい知識 → docs/ (rule からポインタ)

不要と判断したならその旨だけ表明して進めばよい。
EOF
)"

jq -n --arg context "$context" '{additionalContext: $context}'
