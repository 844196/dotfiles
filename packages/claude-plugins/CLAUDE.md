# packages/claude-plugins

Claude Code プラグインのマーケットプレイス。自作スキル・エージェント・フックなどは全てここにプラグインとして実装する。

[`./plugins`](./plugins/) に "新しいプラグインを追加" "既存のプラグインをリネーム" "既存のプラグインを削除" したときは、必ず [ユーザーレベルの Claude Code 設定ファイル](../../files/dot_claude/.chezmoitemplates/settings.json) の `enabledPlugins` と必要があれば `pluginSettings` を更新し `chezmoi apply` すること。

## 落とし穴

- 2026-06-08 時点で [`plugin.json` の ユーザー設定フィールド](https://code.claude.com/docs/ja/plugins-reference#%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E8%A8%AD%E5%AE%9A) の内 `default` は機能していない ([anthropics/claude-code#46477](https://github.com/anthropics/claude-code/issues/46477))
