#!/bin/bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

[[ "$TOOL_NAME" != "Bash" ]] && exit 0

# sleep [31以上] をブロック
if [[ "$COMMAND" =~ sleep[[:space:]]+([0-9]+) ]]; then
  SECONDS="${BASH_REMATCH[1]}"
  if (( SECONDS > 30 )); then
    jq -n '{
      decision: "block",
      reason: "30秒超の sleep はブロック。監視・ポーリングには /loop スキルを使用。"
    }'
    exit 2
  fi
fi

exit 0
