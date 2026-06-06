#!/usr/bin/env bash
# PreToolUse:Write hook: Write が新規ファイル (= file_path が存在しない) を作ろうと
# している場合に deny し、touch → Read → Write の 3 ステップを案内する。
#
# 経緯: Claude Code の `paths` 付き rule (~/.claude/rules/*.md または
# <project>/.claude/rules/*.md) は Read ツール実行時にのみ評価される。Write 単体での
# 新規ファイル作成では発火しないため、新規ファイル作成時はそのファイルが該当しうる
# paths rule のガイドラインを取りこぼす。
#
# 既存ファイルの上書きは Write が Read 経由を要求するため通す。

set -euo pipefail

input="$(cat)"
tool_name="$(jq -r '.tool_name // empty' <<<"$input")"
[ "$tool_name" != "Write" ] && exit 0

file_path="$(jq -r '.tool_input.file_path // empty' <<<"$input")"
[ -z "$file_path" ] && exit 0

# 既存ファイルなら通す (上書きは Read 経由が前提)
[ -e "$file_path" ] && exit 0

reason="[new-file-protocol] 新規ファイルを Write 単体で作ろうとしている。\`paths\` 付き rule (~/.claude/rules/*.md, <project>/.claude/rules/*.md) は Read 時にのみ評価されるため、このまま書くと該当 rule のガイドラインが取りこぼされる。

以下の 3 ステップで作成してください:

1. Bash で \`touch $file_path\` (空ファイル作成)
2. Read で空ファイルを読む (paths 付き rule がここで発火、ガイドラインが注入される)
3. Write で実際の内容を書き込む"

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
