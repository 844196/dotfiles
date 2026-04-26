#!/usr/bin/env bash
# SessionStart hook: edit-reminders の古い session 状態ディレクトリを掃除する。
# reset-turn-state.sh (UserPromptSubmit) は自セッションの state dir しか
# 触らないので、終了したセッションの state dir は残り続ける。
# SessionStart で全体を sweep する。
#
# しきい値: 最終更新が 7 日より前の session dir を削除する。
# 7 日以内に動いていたセッションは温存する (resume されうるため)。
# しきい値を超えても、resume 後の最初の UserPromptSubmit で reset-turn-state.sh が
# 改めて snapshot を取るので、状態を消されても実害は無い。

set -euo pipefail

state_root="${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders"
[ -d "$state_root" ] || exit 0

find "$state_root" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true
