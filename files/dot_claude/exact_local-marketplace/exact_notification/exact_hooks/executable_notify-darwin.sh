#!/bin/bash
# macOS の Notification Center にバナー通知を出す

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "通知があります"')

osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\"" &>/dev/null &

exit 0
