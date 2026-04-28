#!/usr/bin/env bash

set -euo pipefail

~/.local/bin/mise exec -- gh completion --shell zsh > ~/.zsh/vendor-completions/_gh
