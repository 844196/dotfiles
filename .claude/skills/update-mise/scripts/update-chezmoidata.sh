#!/usr/bin/env bash
# Usage:
#   update-chezmoidata.sh latest
#   update-chezmoidata.sh vX.Y.Z
#
# Exit codes:
#   0 - Success or already at target version
#   1 - Error (failed to fetch, release unavailable, etc.)
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
  retry gh release view --repo jdx/mise --json tagName -q '.tagName'
}

get_current_version() {
  jq -r '.versions.mise' "$CHEZMOIDATA"
}

check_release_exists() {
  local version="$1"
  retry gh release view "$version" --repo jdx/mise &>/dev/null
}

update_chezmoidata() {
  local version="$1"
  local tmp
  tmp="$(mktemp)"
  jq --arg v "$version" '.versions.mise = $v' "$CHEZMOIDATA" > "$tmp" \
    && mv "$tmp" "$CHEZMOIDATA"
}

normalize_version() {
  local version="$1"
  # Ensure 'v' prefix
  if [[ "$version" != v* ]]; then
    version="v$version"
  fi
  echo "$version"
}

main() {
  local target="${1:-latest}"
  local current
  current="$(get_current_version)"

  if [[ "$target" == "latest" ]]; then
    target="$(get_latest_version)"
    if [[ -z "$target" ]]; then
      echo "Error: Failed to fetch latest version from jdx/mise" >&2
      exit 1
    fi
  else
    target="$(normalize_version "$target")"
  fi

  if [[ "$current" == "$target" ]]; then
    echo "Already at version $target"
    exit 0
  fi

  if ! check_release_exists "$target"; then
    echo "Error: Release $target not found in jdx/mise" >&2
    echo "Check: https://github.com/jdx/mise/releases" >&2
    exit 1
  fi

  echo "Updating: $current -> $target"
  update_chezmoidata "$target"
  echo "Updated .chezmoidata.json"
}

main "$@"
