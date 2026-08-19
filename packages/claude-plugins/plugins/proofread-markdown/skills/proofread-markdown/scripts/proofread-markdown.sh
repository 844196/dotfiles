#!/usr/bin/env bash
set -euo pipefail

# Usage: proofread-markdown [--fix] <file.md>

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="${script_dir}/../textlintrc.json"
rules_dir="${script_dir}/../rules"
markdownlint_config="${script_dir}/../markdownlintrc.json"

fix_flag=()
target=""

for arg in "$@"; do
  case "$arg" in
    --fix)
      fix_flag=(--fix)
      ;;
    *)
      target="$arg"
      ;;
  esac
done

if [[ -z "$target" ]]; then
  echo "Usage: $(basename "$0") [--fix] <file.md>" >&2
  exit 1
fi

status=0

mise x node@24 \
  npm:textlint \
  npm:textlint-rule-preset-ja-spacing \
  npm:textlint-rule-preset-ja-technical-writing \
  "npm:@textlint-ja/textlint-rule-preset-ai-writing" \
  npm:textlint-rule-preset-jtf-style \
  -- textlint --config "$config_file" --rulesdir "$rules_dir" "${fix_flag[@]}" "$target" || status=$?

mise x node@24 \
  npm:markdownlint-cli2 \
  -- markdownlint-cli2 --config "$markdownlint_config" "${fix_flag[@]}" "$target" || status=$?

exit "$status"
