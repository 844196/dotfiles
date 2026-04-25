---
description: files/dot_claude/ 配下を編集するときに参照する構成
paths:
  - files/dot_claude/**
---

# `files/dot_claude/` の構成

`~/.claude/` にマップされる Claude Code 設定:

- `CLAUDE.md` — 全プロジェクト共通の常時ロード指令
- `exact_rules/*.md` — 自動ロードされる切り出し (`paths` なしは常時ロード、`paths` 付きは該当ファイル Read 時のみ発火)。内容は規範でも知識でもよく、サイズと発火頻度で配置を決める
- `exact_docs/*.md` — Claude Code 自動認識ディレクトリではない自前運用領域。常時ロード rule (`paths` なし) または paths 付き rule からの「詳細: ...」リンク経由でのみ到達可能。rule 本体に直接書くと常時ロードコストや paths 付きでも肥大が問題になる場合の切り出し先
- `exact_hooks/` — hook スクリプト本体 (`settings.json` から登録)
- `skills/CLAUDE.md` — スキル親 CLAUDE.md (`~/.claude/skills/` 配下を読む際にオンデマンドロード)
- `exact_agents/CLAUDE.md` — サブエージェント親 CLAUDE.md
- `settings.json` — Claude Code 設定

自前運用パターンの参考: paths 付き rule (`claude-code-meta`) から大きめの docs (`claude-code-rules.md`、`skills.md`) を発火条件下で参照するペア構成。Claude Code rules/skills の機能仕様自体もこのペアに収めている (詳細は `~/.claude/docs/claude-code-rules.md`、`~/.claude/docs/skills.md`)。
