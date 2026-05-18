# Atuin

Claude Code の Bash ツール実行を [atuin](https://atuin.sh/) のシェル履歴に記録する hook 群。`atuin hook install claude-code` が `settings.json` に直接書き込む 3 つの hook をプラグイン化しつつ、Claude Code のセッション ID を atuin の `session` フィールドに記録する小さな[ラッパースクリプト]を噛ませている。

## What It Does

[hook 定義] では下表 3 イベントを登録し、いずれも matcher は `Bash`。コマンドは[ラッパースクリプト]を経由して `atuin hook claude-code` を呼ぶ。

| Event | atuin 側の動作 |
|---|---|
| `PreToolUse` | Bash ツールの `tool_input.command` を stdin で受け取り、`history start --author claude` 相当を実行 |
| `PostToolUse` | `tool_response.stdout` / `exit_code` を stdin で受け取り、`history end` 相当を実行 |
| `PostToolUseFailure` | 同上 (失敗系イベント) |

[ラッパースクリプト]は stdin JSON から `session_id` を `jq` で抜き、`ATUIN_SESSION` 環境変数に詰めてから `atuin hook claude-code` に転送する。atuin の `History::new` は `ATUIN_SESSION` を `session` フィールドの値として採用するため、追加スキーマ無しで Claude Code セッション ID が `{session}` に乗る。これにより `atuin history list --format '{time}|{session}|{command}'` や `atuin search --filter-mode session` 等で Claude Code セッション単位の絞り込みが可能になる。

[hook 定義]: exact_hooks/hooks.json
[ラッパースクリプト]: exact_hooks/executable_atuin-hook.sh

`atuin hook <agent>` は `atuin hook --help` の subcommand 一覧には出ない隠しコマンドで、agent 名で挙動を分岐させる仕組み。Claude Code 用ハンドラは [Atuin AI Agent Hooks ドキュメント](https://docs.atuin.sh/cli/guide/agent-hooks/) に記載がある。なお handler 本体は stdin JSON の `session_id` を読み捨てている (atuin v18.16.0 時点) ため、上記ラッパーで補っている。

## Why

`atuin hook install claude-code` は便利だが、`~/.claude/settings.json` を直接書き換える上に、書き戻し時に JSON のキーがアルファベット順に再整形される副作用がある。chezmoi 管理下では差分が大きくなりやすく、ソース/実体の往復で揺らぐ。

プラグイン化することで:

- 設定は `hooks.json` に閉じ、`settings.json` を汚さない
- ON/OFF を `enabledPlugins` で切り替えられる
- 他マシン / 他プロジェクトへの展開が `enabledPlugins` の 1 行追加だけで済む
- ラッパースクリプトを差し込める場所が手に入る (= 上述の Claude Code セッション ID 記録)

## Requirements

- atuin v18.16.0 以降 (`atuin hook` サブコマンドの導入バージョン) が PATH 上にあること
- `jq` が PATH 上にあること ([ラッパースクリプト]が stdin JSON のパースに使用)
