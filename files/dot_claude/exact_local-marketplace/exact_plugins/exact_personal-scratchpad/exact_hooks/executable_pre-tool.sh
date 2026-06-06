#!/usr/bin/env bash
# PreToolUse:Edit|Write|Bash hook: .844196/ を含むパスへの操作を検出し警告する。
#
# .844196/ は gitignore されているため、git restore で復元できない。
# 破壊的操作の前に警告を出して注意を促す。

set -euo pipefail

input="$(cat)"
tool_name="$(jq -r '.tool_name // empty' <<<"$input")"

case "$tool_name" in
  Edit|Write)
    target="$(jq -r '.tool_input.file_path // empty' <<<"$input")"
    ;;
  Bash)
    target="$(jq -r '.tool_input.command // empty' <<<"$input")"
    ;;
  *)
    exit 0
    ;;
esac

[ -z "$target" ] && exit 0

# .844196/ を含まなければ通す
[[ "$target" != *".844196/"* ]] && exit 0

warning="[personal-scratchpad] .844196/ は gitignore されているため、git restore で復元できない。破壊的操作 (上書き、削除、移動など) を行う前に:

- 移動先に同名ファイルが存在しないか確認する
- 上書きの影響範囲を確認する
- 必要なら事前にバックアップを取る"

jq -n --arg warning "$warning" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $warning
  }
}'
