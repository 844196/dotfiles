#!/usr/bin/env bash

set -euo pipefail

if ! which launchctl &>/dev/null; then
  exit
fi

launchctl unload ~/Library/LaunchAgents/sh.844196.chromad.plist || true
