#!/bin/bash

set -euo pipefail

if ! which systemctl &>/dev/null; then
  exit
fi

if systemctl --user is-active chromad.service &>/dev/null; then
  systemctl --user stop chromad.service
fi

if systemctl --user is-enabled chromad.service &>/dev/null; then
  systemctl --user disable chromad.service
fi
