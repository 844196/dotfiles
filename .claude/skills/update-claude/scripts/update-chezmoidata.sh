#!/usr/bin/env bash
# Usage:
#   update-chezmoidata.sh latest
#   update-chezmoidata.sh X.Y.Z
#
# Exit codes:
#   0 - Success or already at target version
#   1 - Error (failed to fetch, system prompts unavailable, etc.)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHEZMOIDATA="$SCRIPT_DIR/../../../../files/.chezmoidata.json"
MAX_RETRIES=3

retry() {
  local attempt=1
  while (( attempt <= MAX_RETRIES )); do
    if "$@"; then
      return 0
    fi
    echo "Attempt $attempt/$MAX_RETRIES failed, retrying..." >&2
    (( attempt++ ))
    sleep 1
  done
  return 1
}

get_latest_version() {
  retry curl -sf --connect-timeout 10 --max-time 30 https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r '.version'
}

get_current_version() {
  jq -r '.versions.claude' "$CHEZMOIDATA"
}

check_system_prompts() {
  local version="$1"
  retry gh release view "v${version}" --repo Piebald-AI/claude-code-system-prompts &>/dev/null
}

update_chezmoidata() {
  local version="$1"
  local tmp
  tmp="$(mktemp)"
  jq --arg v "$version" '.versions.claude = $v' "$CHEZMOIDATA" > "$tmp" \
    && mv "$tmp" "$CHEZMOIDATA"
}

main() {
  local target="${1:-latest}"
  local current
  current="$(get_current_version)"

  # Strip 'v' prefix if present
  target="${target#v}"

  if [[ "$target" == "latest" ]]; then
    target="$(get_latest_version)"
    if [[ -z "$target" ]]; then
      echo "Error: Failed to fetch latest version from npm" >&2
      exit 1
    fi
  fi

  if [[ "$current" == "$target" ]]; then
    echo "Already at version $target"
    exit 0
  fi

  if ! check_system_prompts "$target"; then
    echo "Error: System prompts not available for v${target}" >&2
    echo "Check: https://github.com/Piebald-AI/claude-code-system-prompts/releases" >&2
    exit 1
  fi

  echo "Updating: $current -> $target"
  update_chezmoidata "$target"
  echo "Updated .chezmoidata.json"
}

main "$@"
