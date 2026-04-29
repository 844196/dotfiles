#!/usr/bin/env bash
# SessionStart hook: 新規ファイル作成プロトコルを additionalContext として
# 事前にエージェントへ通知する。
#
# 経緯: PreToolUse:Write での deny だけだと、エージェントが連続して新規ファイルを
# Write しようとした際に大量のブロックが発生する。プラグインは rule (paths 付き)
# を提供できないため、SessionStart で additionalContext を注入することで
# 「事前告知」として同等の効果を得る。
#
# deny は引き続き残るので、エージェントが告知を無視した場合のフェイルセーフとして機能する。

set -euo pipefail

context='[new-file-protocol] このセッションでは新規ファイル作成プロトコルが有効です。

`Write` ツール単体での新規ファイル作成は PreToolUse hook によって deny されます。`paths` 付き rule (~/.claude/rules/*.md, <project>/.claude/rules/*.md) は Read ツール実行時にのみ評価されるため、Write 単体では該当 rule のガイドラインが取りこぼされるからです。

新規ファイルを作成する場合は、必ず以下の 3 ステップで作成してください:

1. Bash で `touch <file_path>` (空ファイル作成)
2. Read で空ファイルを読む (paths 付き rule がここで発火、ガイドラインが注入される)
3. Write で実際の内容を書き込む

既存ファイルの上書きは Write が Read 経由を要求するため、このプロトコルの対象外です。'

jq -n --arg context "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $context
  }
}'
