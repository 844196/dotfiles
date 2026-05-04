#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_checks="${script_dir}/../references/default-checklist.md"

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)

if [ -n "$repo_root" ] && [ -f "${repo_root}/.claude/done-check.local.md" ]; then
  cat "${repo_root}/.claude/done-check.local.md"
elif [ -n "$repo_root" ] && [ -f "${repo_root}/.claude/done-check.md" ]; then
  cat "${repo_root}/.claude/done-check.md"
else
  cat "$default_checks"
fi
