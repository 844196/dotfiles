#!/bin/bash

set -euo pipefail

if which systemctl &>/dev/null; then
  systemctl --user enable chromad.service
  systemctl --user start chromad.service
fi

if which launchctl &>/dev/null; then
  launchctl load ~/Library/LaunchAgents/sh.844196.chromad.plist
fi
