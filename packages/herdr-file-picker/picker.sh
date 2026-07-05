#!/usr/bin/env bash
set -euo pipefail

# HERDR_PANE_ID はオーバーレイペインの ID
# .focused_pane_id が呼び出し元のペイン ID
callback_pane_id=$(jq -r '.focused_pane_id' <<<"${HERDR_PLUGIN_CONTEXT_JSON:?}")

export PLAIN_PROMPT='❯ '
export PLAIN_POINTER='🈚'
export ATMARK_PROMPT='@ '
export ATMARK_POINTER='🈁'

initial_prompt="$PLAIN_PROMPT"
initial_pointer="$PLAIN_POINTER"
if [[ "${PICKER_INITIAL_MODE:-}" == "atmark" ]];then
  initial_prompt="$ATMARK_PROMPT"
  initial_pointer="$ATMARK_POINTER"
fi

toggle_mode() {
  if [[ "$FZF_PROMPT" == *${PLAIN_PROMPT}* ]]; then
    printf 'change-prompt(%s)+change-pointer(%s)' "$ATMARK_PROMPT" "$ATMARK_POINTER"
  else
    printf 'change-prompt(%s)+change-pointer(%s)' "$PLAIN_PROMPT" "$PLAIN_POINTER"
  fi
}

format() {
  if [[ "$FZF_PROMPT" == *${PLAIN_PROMPT}* ]]; then
    cat -
  else
    sed 's/^/@/g'
  fi
}

export -f toggle_mode format

picked=$(
  fd --strip-cwd-prefix --hidden --no-ignore-vcs --exclude .git --exclude node_modules \
    | fzf --multi --prompt "$initial_prompt" --pointer "$initial_pointer" \
        --with-shell 'bash -c' \
        --bind '@:transform:toggle_mode' \
        --bind 'enter:become(printf "%q\n" {+} | format)'
) || exit 0

if [[ -z "$picked" ]]; then
  exit 0
fi

herdr pane send-text ${callback_pane_id:?} "$picked"
