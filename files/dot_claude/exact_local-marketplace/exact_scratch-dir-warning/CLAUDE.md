# Scratch Dir Warning

`.844196/` (個人スクラッチディレクトリ) への操作を検出し、システムリマインダーで警告を注入する hook。gitignore されているため `git restore` で復元できないことを注意喚起し、破壊的操作の前に確認を促す。

## What It Does

| Hook | Event | Matcher | 動作 |
|---|---|---|---|
| [`pre-tool.sh`](exact_hooks/executable_pre-tool.sh) | `PreToolUse` | `Edit\|Write\|Bash` | `tool_input.file_path` または `tool_input.command` に `.844196/` が含まれていたら `additionalContext` で警告を注入 |
| [`session-start.sh`](exact_hooks/executable_session-start.sh) | `SessionStart` | (なし: 全 source) | `additionalContext` で注意事項を事前告知 |

警告は `additionalContext` として注入されるため、操作はブロックせず通る。エージェントが警告を見て判断することを期待する。

## Why

セッション分析レポート (`.844196/reports/20260512-session-analysis/README.md`) で特定された問題:

- **#18 破壊的操作の事前確認不足**: ユーザーの指示は「README.md を移動させて」だったが、移動先にも既に README.md が存在していた。`mv` コマンドで同名ファイルを上書きしてしまい、3 つのファイル内容が消失。gitignore 対象のディレクトリであるため、git restore での復元も不可能だった。
- **#19 後知恵的な問題認識**: 移動後の `ls` で README.md が 0 バイトであることを確認し、問題に気づいたが、能動的に復元を試みなかった。
- **#20 指示の解釈確認をしなかった**: エージェントの thinking で確認が必要かもしれないと認識していたにもかかわらず、確認せずに実行。

このプラグインは `.844196/` への操作時に警告を出すことで、同様の事故を防ぐ。

## Configuration

このプラグインを有効化するには、Claude Code の `settings.json` で `enabledPlugins` に追加する:

```json
{
  "enabledPlugins": {
    "scratch-dir-warning@local": true
  }
}
```
