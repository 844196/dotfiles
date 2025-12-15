#!/bin/bash

set -euo pipefail

if ! which systemctl &>/dev/null; then
  exit
fi

systemctl --user daemon-reload
