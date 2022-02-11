export FZF_DEFAULT_OPTS="
  --reverse
  --multi
  --exit-0
  --cycle
  --no-info
  --ansi
  --height 90%
  --prompt=' '
  --pointer='❯'
  --marker='❯'
  --query \"'\"
  --border=horizontal
  --preview-window 'bottom,80%,border-top'
  --bind '?:change-preview-window(hidden|right,75%,border-left|bottom,80%,border-top)'
"

# see: https://gist.github.com/sheepla/d1ff1ef11cc21dcc7434a25a012a970f
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=bg:#161821
  --color=bg+:#1e2132
  --color=fg:#c6c8d1
  --color=fg+:#c6c8d1
  --color=hl:#6b7089
  --color=hl+:#84a0c6
  --color=spinner:#84a0c6
  --color=header:#6b7089
  --color=border:#34394E
  --color=gutter:#161821
  --color=info:#b4be82
  --color=pointer:#84a0c6
  --color=marker:#84a0c6
  --color=prompt:#454b68
'
