---
description: files/dot_claude/ 配下を編集するときに参照する構成
paths:
  - files/dot_claude/**
---

# `files/dot_claude/` の構成

`~/.claude/` にマップされる Claude Code 設定:

- `literal_CLAUDE.md` — 全プロジェクト共通の常時ロード指令 (`literal_` で chezmoi に prefix 解釈をスキップさせ、ターゲットでは `~/.claude/CLAUDE.md` として配置される。ソース側のファイル名を `CLAUDE.md` から外しているのは、このリポジトリ上のエージェントが `~/.claude/CLAUDE.md` 用の指令を誤って自リポジトリの memory として読み込むのを防ぐため)
- `exact_rules/*.md` — 自動ロードされる切り出し (`paths` なしは常時ロード、`paths` 付きは該当ファイル Read 時のみ発火)。内容は規範でも知識でもよく、サイズと発火頻度で配置を決める
- `exact_docs/*.md` — Claude Code 自動認識ディレクトリではない自前運用領域。常時ロード rule (`paths` なし) または paths 付き rule からの「詳細: ...」リンク経由でのみ到達可能。rule 本体に直接書くと常時ロードコストや paths 付きでも肥大が問題になる場合の切り出し先
- `exact_hooks/` — hook スクリプト本体 (`settings.json` から登録)
- `exact_agents/`, `exact_skills/` — サブエージェント・スキル定義の置き場。ソース編集時のメモは `~/.claude/agents/CLAUDE.md` などに置かず、このリポジトリの `.claude/rules/dot-claude-agents.md` / `.claude/rules/dot-claude-skills.md` (paths 付き) に置く
- `settings.json` — Claude Code 設定

自前運用パターンの参考: paths 付き rule (`claude-code-meta`) から大きめの docs (`claude-code-rules.md`、`skills.md`) を発火条件下で参照するペア構成。Claude Code rules/skills の機能仕様自体もこのペアに収めている (詳細は `~/.claude/docs/claude-code-rules.md`、`~/.claude/docs/skills.md`)。
