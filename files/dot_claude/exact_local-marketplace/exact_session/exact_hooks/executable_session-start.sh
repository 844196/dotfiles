#!/usr/bin/env bash
# SessionStart hook: session プラグインの session-analyzer エージェントの
# proactive 発動条件を additionalContext として事前告知する。
#
# 経緯: トリガー条件をエージェント description に書くと description が肥大し、
# またハンドオーバーテンプレ等の他文書とも記述が散らばる。プラグイン側で
# システムリマインダーとして注入することでプラグインの enable/disable と
# 連動した一元管理にする。mise プラグインの session-start.sh と同じパターン。

set -euo pipefail

context='[session] このセッションでは session プラグインが有効です。

session:session-analyzer エージェントの自動発動条件 (ユーザーの指示を待たずに spawn してよい):
- 会話の最初のユーザーメッセージがハンドオーバー文書 (`.844196/handovers/<datetime>_<kebab>.md` を `@` で参照) で始まっており、文書に書かれていない詳細が必要になったとき。セッション ID はハンドオーバー文書の「参考」セクションにある (`前のセッション: <UUID>`)
- ユーザーが「前のセッションで」「以前に決めた」「あの時の経緯」のように現セッション外の過去を参照し、かつセッション ID が手がかりとして特定できるとき (ハンドオーバー文書経由、ユーザー提示など)

呼ばないケース:
- セッション ID が一切手がかりとして無いとき (ハンドオーバーから始まっていない、かつユーザーも提示していない)
- 現セッション内で完結する話題のとき'

jq -n --arg context "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $context
  }
}'
