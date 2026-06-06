#!/bin/bash
# tmux の monitor-bell を発火させるため、Claude のペインの tty に BEL を書き出す
# (hook の起動コンテキストでは /dev/tty が解決できないことがあるので、TMUX_PANE から引く)

cat >/dev/null  # stdin の hook input は捨てる

if [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
  pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null) || pane_tty=""
  [ -n "$pane_tty" ] && printf '\a' > "$pane_tty" 2>/dev/null || true
fi

exit 0
