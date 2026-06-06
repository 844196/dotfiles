#!/bin/bash
set -euo pipefail

input=$(cat)
sid=$(jq -r '.session_id // empty' <<<"$input")

if [ -n "$sid" ]; then
  ATUIN_SESSION="$sid" atuin hook claude-code <<<"$input"
else
  atuin hook claude-code <<<"$input"
fi
