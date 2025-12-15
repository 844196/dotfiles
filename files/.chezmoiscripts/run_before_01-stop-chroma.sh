#!/bin/bash

set -euo pipefail

if ! which systemctl &>/dev/null; then
  exit
fi

if systemctl --user is-active chroma.service &>/dev/null; then
  systemctl --user stop chroma.service
fi

if systemctl --user is-enabled chroma.service &>/dev/null; then
  systemctl --user disable chroma.service
fi
