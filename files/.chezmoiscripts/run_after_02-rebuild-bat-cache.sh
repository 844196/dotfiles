#!/bin/bash

bat="$(~/.local/share/aquaproj-aqua/bin/aqua -c ~/.config/aquaproj-aqua/aqua.yaml which bat)"

exec "$bat" cache --build >/dev/null
