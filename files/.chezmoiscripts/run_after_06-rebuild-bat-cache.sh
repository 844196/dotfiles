#!/bin/bash

set -euo pipefail

~/.local/bin/mise exec -- bat cache --build >/dev/null
