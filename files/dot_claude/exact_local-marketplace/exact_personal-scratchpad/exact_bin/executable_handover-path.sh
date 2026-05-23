#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HANDOVER_ROOT="$REPO_ROOT/.844196/handovers"

mkdir -p "$HANDOVER_ROOT"

echo "$HANDOVER_ROOT/$(date +%Y%m%d-%H%M%S)_<kebab-case>.md"
