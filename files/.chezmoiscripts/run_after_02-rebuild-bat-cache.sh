#!/bin/bash

bat="$(~/.local/bin/aqua which bat)"

exec "$bat" cache --build >/dev/null
