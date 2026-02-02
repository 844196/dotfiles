#!/bin/bash

set -euo pipefail

if ! which systemctl &>/dev/null; then
  exit
fi

systemctl --user start chromad.service
systemctl --user enable chromad.service
