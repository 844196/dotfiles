#!/usr/bin/env bash
set -euo pipefail

exec "${HERDR_BIN_PATH:?}" plugin pane open \
  --plugin 844196.file-picker \
  --entrypoint picker \
  --cwd "$(jq -r '.focused_pane_cwd' <<<"${HERDR_PLUGIN_CONTEXT_JSON:?}")"
