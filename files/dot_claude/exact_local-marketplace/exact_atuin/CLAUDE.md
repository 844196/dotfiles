# Atuin

Claude Code の Bash ツール実行を [atuin](https://atuin.sh/) のシェル履歴に記録する hook 群。`atuin hook install claude-code` が `settings.json` に直接書き込む 3 つの hook と同等のものを、プラグインとして提供する。

## What It Does

[hook 定義] では下表 3 イベントを登録し、いずれも matcher は `Bash`、コマンドは `atuin hook claude-code` を実行する。

| Event | atuin 側の動作 |
|---|---|
| `PreToolUse` | Bash ツールの `tool_input.command` を stdin で受け取り、`history start --author claude` 相当を実行 |
| `PostToolUse` | `tool_response.stdout` / `exit_code` を stdin で受け取り、`history end` 相当を実行 |
| `PostToolUseFailure` | 同上 (失敗系イベント) |

[hook 定義]: exact_hooks/hooks.json

`atuin hook <agent>` は `atuin hook --help` の subcommand 一覧には出ない隠しコマンドで、agent 名で挙動を分岐させる仕組み。Claude Code 用ハンドラは [Atuin AI Agent Hooks ドキュメント](https://docs.atuin.sh/cli/guide/agent-hooks/) に記載がある。

## Why

`atuin hook install claude-code` は便利だが、`~/.claude/settings.json` を直接書き換える上に、書き戻し時に JSON のキーがアルファベット順に再整形される副作用がある。chezmoi 管理下では差分が大きくなりやすく、ソース/実体の往復で揺らぐ。

プラグイン化することで:

- 設定は `hooks.json` に閉じ、`settings.json` を汚さない
- ON/OFF を `enabledPlugins` で切り替えられる
- 他マシン / 他プロジェクトへの展開が `enabledPlugins` の 1 行追加だけで済む

## Requirements

- atuin v18.16.0 以降 (`atuin hook` サブコマンドの導入バージョン) が PATH 上にあること
