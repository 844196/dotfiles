#!/bin/bash

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

if [[ "$FILE_PATH" == *.md ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: "[doc-consistency] ドキュメントを編集した。全ての編集が完了した後、以下を確認すること:\n- 全文を読み返し、内部矛盾・用語の揺れ・重複がないか\n- 見出し階層（h1/h2/h3）が論理的に正しいか（挿入で既存セクションの見出しが欠落していないか）\n- 関連ドキュメント（相互参照先、同ディレクトリ内の関連ファイル）との整合性"
    }
  }'
fi

exit 0
