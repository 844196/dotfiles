#!/usr/bin/env bash
set -euo pipefail

# herdr には tmux の select-layout even-* に相当する機能がないため、
# pane move を組み合わせて疑似的に再現する。
#
# HERDR_PLUGIN_ACTION_ID で挙動を分岐する:
#   even-horizontal -> | A | B | C |  (横並び / split direction = right)
#   even-vertical   ->   A / B / C    (縦積み   / split direction = down)
#   toggle          -> 現在の向きを判定して逆向きへ (tmux の prefix+space 風)
#
# コンテキストは HERDR_PLUGIN_CONTEXT_JSON (JSON) で渡される。

herdr() { "${HERDR_BIN_PATH:?}" "$@"; }

action_id="${HERDR_PLUGIN_ACTION_ID:?}"

context="${HERDR_PLUGIN_CONTEXT_JSON:?}"
focused_pane_id=$(jq -r '.focused_pane_id // empty' <<<"$context")
if [[ -z "$focused_pane_id" ]]; then
  echo "focused pane not found in context" >&2
  exit 1
fi

# 現在のフォーカスペインが属する tab のレイアウトを取得する。
# layout は左->右 / 上->下 の順にペインを返すので、その順序を並び順として尊重する。
layout=$(herdr pane layout --pane "$focused_pane_id")

tab_id=$(jq -r '.result.layout.tab_id' <<<"$layout")
mapfile -t panes < <(jq -r '.result.layout.panes[].pane_id' <<<"$layout")

# 目的の split 方向を決める。toggle は現在の向きから逆を選ぶ。
case "$action_id" in
  even-horizontal) split_dir="right" ;;
  even-vertical)   split_dir="down" ;;
  toggle)
    # split の direction を集計して現在の向きを推定する。
    #   全て right      -> 今は横並び       -> vertical へ倒す
    #   全て down       -> 今は縦積み       -> horizontal へ倒す
    #   混在 / split なし -> どちらでもない   -> vertical を既定にする
    mapfile -t dirs < <(jq -r '.result.layout.splits[].direction' <<<"$layout")
    has_right=0 has_down=0
    for d in "${dirs[@]:-}"; do
      [[ "$d" == "right" ]] && has_right=1
      [[ "$d" == "down" ]] && has_down=1
    done
    if (( has_right == 1 && has_down == 0 )); then
      split_dir="down"        # 横並び -> 縦積み
    else
      split_dir="right"       # 縦積み・混在・不定 -> 横並び
    fi
    ;;
  *) echo "unknown action: $action_id" >&2; exit 1 ;;
esac

n=${#panes[@]}
if (( n <= 1 )); then
  # 1 枚以下なら整列する対象がない。
  exit 0
fi

# 手順:
#   1. 先頭ペイン(base)を土台として残し、残りを一旦別 tab へ退避する。
#      (同一 tab 内の move は same_tab で no-op になるため、必ず tab をまたぐ必要がある)
#   2. 退避したペインを base の隣へ順に挿し直す。
base="${panes[0]}"
rest=("${panes[@]:1}")

# 1. 退避
declare -a stashed=()
for p in "${rest[@]}"; do
  herdr pane move "$p" --new-tab --no-focus >/dev/null
  stashed+=("$p")
done

# 2. 挿し直し
prev="$base"
remaining=$n            # まだ整列しきっていないペイン数 (prev 含む)
for p in "${stashed[@]}"; do
  # --ratio は「新規に入るペイン(=p)」の取り分。
  # p を prev の隣へ挿すとき、prev のサブツリーには prev 自身とこの先に挿す
  # ペイン (remaining-1 枚) が入るので、p には全体の 1/remaining を渡すと均等になる。
  # (実機検証: move --ratio 0.5 単発で 3 枚が 79/78/79 に均等化することを確認)
  ratio=$(awk -v r="$remaining" 'BEGIN{ printf "%.6f", 1.0 / r }')

  # フォーカス保持: 通常ペインを狙って focus する手段が無いので、
  # 元々フォーカスされていたペインを挿し直すこの瞬間に --focus を乗せる。
  # それ以外は --no-focus。元フォーカスが base だった場合は stashed に無いが、
  # base は動かさず全 move が --no-focus なので結果的に base にフォーカスが残る。
  if [[ "$p" == "$focused_pane_id" ]]; then
    focus_flag="--focus"
  else
    focus_flag="--no-focus"
  fi
  herdr pane move "$p" --tab "$tab_id" --split "$split_dir" \
    --target-pane "$prev" --ratio "$ratio" "$focus_flag" >/dev/null
  prev="$p"
  remaining=$((remaining - 1))
done

# フォーカスについて:
# herdr には「通常ペインをピンポイントで focus する」CLI/API が無い
# (pane focus は --direction 必須の相対移動、plugin pane focus はプラグイン製ペイン専用)。
# そのため退避・挿し直しはすべて --no-focus で行い、こちらからは能動的に
# フォーカスを動かさず、herdr が決めたフォーカスに委ねる。
