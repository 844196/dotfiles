# `files/dot_claude/` (`~/.claude/`)

`~/.claude/CLAUDE.md` は使用しない。トピックごとに `exact_rules/*.md` に分割して管理する。
- `exact_local-marketplace/` — ローカル専用プラグインのマーケットプレイス。自作スキル・エージェント・hook はすべてここにプラグインとして配置する (`~/.claude/skills/` は apm 専用、`~/.claude/agents/` は使用しない)。
  - 関連するスキル / hook をまとめてバンドルしたい、または構成要素が一つでも実装背景の説明が必要な場合に1プラグインとして切り出す。
  - プラグインの ON/OFF は `settings.json.tmpl` の `enabledPlugins` で制御する。常時欲しいものは true、特定プロジェクトでのみ必要なものは false にしてプロジェクト側 `.claude/settings.local.json` で上書きする運用。
