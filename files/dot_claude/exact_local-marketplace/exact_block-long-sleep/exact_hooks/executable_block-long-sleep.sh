#!/bin/bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

[[ "$TOOL_NAME" != "Bash" ]] && exit 0

# sleep N[smhd] を全箇所スキャン。1つでも 25秒以上ならブロック
while IFS= read -r match; do
  [[ -z "$match" ]] && continue
  [[ "$match" =~ sleep[[:space:]]+([0-9]+)([smhd]?) ]] || continue
  num="${BASH_REMATCH[1]}"
  case "${BASH_REMATCH[2]}" in
    ""|s) seconds=$num ;;
    m)    seconds=$((num * 60)) ;;
    h)    seconds=$((num * 3600)) ;;
    d)    seconds=$((num * 86400)) ;;
  esac
  if (( seconds >= 25 )); then
    jq -n '{
      decision: "block",
      reason: "25秒以上の sleep はブロック。代替手段:\n- 完了待ち: Bash ツールの run_in_background オプション\n- 状態変化の監視 (ログ・プロセス・コマンド出力): Monitor ツール\n- 定期的な LLM 判断: CronCreate ツール (/loop スキルから呼べる)"
    }'
    exit 2
  fi
done < <(echo "$COMMAND" | grep -oE 'sleep[[:space:]]+[0-9]+[smhd]?')

exit 0
