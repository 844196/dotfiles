#!/usr/bin/env bash
# SessionStart / UserPromptSubmit hook: CWD が git リポジトリルートからズレている場合
# additionalContext でリマインドする。
#
# 経緯: エージェントが作業中に Bash の `cd` で CWD を移動したあと、その事実を忘れて
# 相対パスでコマンドを実行してしまい、ワークフローが破綻するケースがある。
# セッション開始時 (resume / clear / compact 含む) と各ユーザープロンプト送信時に
# CWD と git リポジトリルートを比較し、ズレていたら現在地を再告知する。
#
# git 配下にない CWD ではそもそも比較対象がないので無言で終了する。

set -euo pipefail

input="$(cat)"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
event="$(jq -r '.hook_event_name // empty' <<<"$input")"

[ -z "$cwd" ] && exit 0
[ -z "$event" ] && exit 0

# git 配下にない場合はそもそも比較対象がない
root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && exit 0

# リポジトリルートにいるなら何もしない
[ "$cwd" = "$root" ] && exit 0

case "$event" in
  SessionStart)
    context="[cwd-reminder] セッション開始時点で CWD が git リポジトリルートと一致しません。

- CWD: \`$cwd\`
- リポジトリルート: \`$root\`

意図して別の場所で作業する場合を除き、相対パスの誤用を防ぐためリポジトリルートから作業を開始することを推奨します:

- 特に意図がなければ、最初に \`cd $root\` でリポジトリルートに移動する
- 意図的にこの CWD で作業する場合は続行してよい"
    ;;
  *)
    context="[cwd-reminder] 現在の CWD は git リポジトリルートではありません。

- CWD: \`$cwd\`
- リポジトリルート: \`$root\`

エージェントが \`cd\` 後に CWD を忘れて相対パスでコマンドを実行するとワークフローが破綻します。次の方針で対処してください:

- このリマインダーを受け取った時点で、すぐにリポジトリルートに戻る (\`cd $root\`)
- どうしても今の CWD で続ける必要がある場合は続行してよいが、作業完了後はリポジトリルートに戻る"
    ;;
esac

jq -n --arg context "$context" --arg event "$event" '{
  hookSpecificOutput: {
    hookEventName: $event,
    additionalContext: $context
  }
}'
