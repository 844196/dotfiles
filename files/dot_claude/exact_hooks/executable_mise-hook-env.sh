#!/usr/bin/env zsh
set -euo pipefail

mise hook-env -s zsh --force >> "$CLAUDE_ENV_FILE"
