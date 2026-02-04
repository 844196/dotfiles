#!/bin/bash

set -euo pipefail

if which systemctl &>/dev/null; then
  if systemctl --user is-active chromad.service &>/dev/null; then
    systemctl --user stop chromad.service
  fi

  if systemctl --user is-enabled chromad.service &>/dev/null; then
    systemctl --user disable chromad.service
  fi
fi

if which launchctl &>/dev/null; then
  launchctl unload ~/Library/LaunchAgents/sh.844196.chromad.plist || true
fi
