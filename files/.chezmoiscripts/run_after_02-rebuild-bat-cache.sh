#!/bin/bash

bat="$(~/.local/bin/aqua -c ~/.config/aquaproj-aqua/aqua.yaml which bat)"

exec "$bat" cache --build >/dev/null
