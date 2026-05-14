#!/usr/bin/env bash
# SessionStart hook: .844196/ への操作に関する注意を事前告知する。

set -euo pipefail

context="[scratch-dir-warning] このセッションでは scratch-dir-warning プラグインが有効です。

.844196/ (個人スクラッチディレクトリ) は gitignore されているため、git restore で復元できません。このディレクトリ以下のファイルを編集・移動・削除する際は、破壊的操作を行う前に:

- 移動先に同名ファイルが存在しないか確認する
- 上書きの影響範囲を確認する
- 必要なら事前にバックアップを取る"

jq -n --arg context "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $context
  }
}'
