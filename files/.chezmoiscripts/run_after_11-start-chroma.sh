#!/bin/bash

set -euo pipefail

if ! which systemctl &>/dev/null; then
  exit
fi

systemctl --user start chroma.service
systemctl --user enable chroma.service
