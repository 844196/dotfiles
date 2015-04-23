#!/bin/bash

keystroke="$(echo "${0}" | sed -e "s;.*_\([^\.]*\).*;\1;g")"
windowID="$(xdotool getwindowfocus)"

xdotool key --window "${windowID}" "${keystroke}" >/dev/null 2>&1
