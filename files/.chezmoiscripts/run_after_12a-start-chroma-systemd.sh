#!/usr/bin/env bash

set -euo pipefail

if ! which systemctl &>/dev/null; then
  exit
fi

systemctl --user enable chromad.service
systemctl --user start chromad.service
