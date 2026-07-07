#!/usr/bin/env bash
set -euo pipefail

# 先に標準入力を消費して BrokenPipe を回避する
query=$(jq -r '.query // ""')
if [[ -n "$query" ]]; then
  exit 0
fi

if [[ -z "${HERDR_ENV:-}" ]]; then
  exit 0
fi

herdr pane send-keys ${HERDR_PANE_ID:?} backspace

herdr plugin pane open \
  --plugin 844196.file-picker \
  --entrypoint picker \
  --cwd "${CLAUDE_PROJECT_DIR:-$PWD}" \
  --env PICKER_INITIAL_MODE=atmark \
  > /dev/null 2>&1
