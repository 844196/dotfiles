#!/bin/bash

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

if [[ "$FILE_PATH" == *.md ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: "[doc-consistency] 全編集完了後に確認:\n- 内部矛盾・用語の揺れ・重複がないか\n- 見出し階層（h1/h2/h3）が論理的に正しいか\n- 関連ドキュメント（相互参照先、同ディレクトリ内の関連ファイル）との整合性\n- リソース名の明確化: 略称や代名詞が「後から読み返した時にどこの何を指すかわかる」か\n- 断定表現の根拠: 「判明」「確定」等を使う場合、エビデンスが明示されているか\n- 比較セクションの対称性: 比較対象間で記載項目が揃っているか"
    }
  }'
fi

exit 0
