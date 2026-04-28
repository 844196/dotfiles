#!/bin/bash

set -euo pipefail

if type lesskey >/dev/null 2>&1; then
  lesskey -o ~/.config/less/.less ~/.config/less/.lesskey
fi
