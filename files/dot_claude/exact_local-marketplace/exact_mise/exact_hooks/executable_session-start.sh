#!/usr/bin/env bash
# SessionStart hook: mise プロジェクトでのエージェントの立ち振る舞いを
# additionalContext として事前告知する。
#
# 経緯: 元々 ~/.claude/rules/mise-tasks.md として常時ロードしていたが、
# 中身は「mise タスク機能の説明」ではなく「mise を使うプロジェクトに居合わせた
# エージェントへの指令」だったため、プラグインの enable/disable と連動する
# SessionStart additionalContext に格上げした。new-file-protocol プラグインの
# session-start.sh と同じパターン。

set -euo pipefail

context='[mise] このセッションでは mise プラグインが有効です。

mise を使うプロジェクトでのエージェントの立ち振る舞い:

- mise タスクの実行・定義・変更を行う際は `mise:using-mise-tasks` スキルを参照する
- プロジェクトルートに `mise.toml` がある場合、ビルド/テスト/リント等のタスク実行は npm/yarn/pnpm 等のランタイム固有ランナーより `mise run <task>` を優先する'

jq -n --arg context "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $context
  }
}'
