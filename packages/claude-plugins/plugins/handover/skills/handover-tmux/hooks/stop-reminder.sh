#!/usr/bin/env bash
set -euo pipefail

reminder="[handover-tmux] 以下を自己点検してください:

- 手順1 (ハンドオーバ文書の書き出し) は完了したか?
- 手順2 (新しいペインの Claude Code セッションへ引き継ぎ) は実行したか?
- 手順3 (報告) は実行したか?

**手順2が未実行ならただちに実行してください**。

既に全手順を完了している場合は、このリマインダーを無視して構いません。"

jq -n --arg ctx "$reminder" '{
  hookSpecificOutput: {
    hookEventName: "Stop",
    additionalContext: $ctx
  }
}'
