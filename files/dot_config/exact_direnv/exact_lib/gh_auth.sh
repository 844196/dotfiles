#!/usr/bin/env bash
set -euo pipefail

gh_auth() {
  if output=$(gh auth switch -u $1 2>&1); then
    log_status "Switched active GitHub account to $1"
  else
    ret=$?
    log_error "Failed to switch GitHub account to $1"
    log_error "$output"
    return $ret
  fi
}
