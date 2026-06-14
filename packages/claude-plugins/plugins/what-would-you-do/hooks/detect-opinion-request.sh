#!/bin/bash
set -euo pipefail

INPUT=$(cat)
PROMPT=$(jq -r '.prompt // ""' <<<"$INPUT")

if grep -qE 'どう(思う|おもう)[?？]' <<<"$PROMPT"; then
  jq -n --rawfile ctx "${CLAUDE_PLUGIN_ROOT}/hooks/inject.md" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    }
  }'
fi

exit 0
