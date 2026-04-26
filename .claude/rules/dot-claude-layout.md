---
description: files/dot_claude/ 配下を編集するときに参照する構成
paths:
  - files/dot_claude/**
---

# `files/dot_claude/` の構成

`~/.claude/` にマップされる Claude Code 設定:

- `literal_CLAUDE.md` — 常時ロード指令。`literal_` で chezmoi に prefix 解釈をスキップさせ、ターゲットでは `~/.claude/CLAUDE.md` として配置される (ソース側のファイル名を `CLAUDE.md` から外しているのは、このリポジトリ上のエージェントが `~/.claude/CLAUDE.md` 用の指令を誤って自リポジトリの memory として読み込むのを防ぐため)
- `exact_rules/*.md` — 自動ロードされる切り出し (`paths` なしは常時ロード、`paths` 付きは該当ファイル Read 時のみ発火)。
- `exact_docs/*.md` — Claude Code 自動認識ディレクトリではない自前運用領域。常時ロード rule (`paths` なし) または paths 付き rule からの「詳細: ...」リンク経由でのみ到達可能。rule 本体に直接書くと常時ロードコストや paths 付きでも肥大が問題になる場合の切り出し先
- `exact_hooks/` — hook スクリプト本体 (`settings.json` の `hooks` から直接登録するもの)
- `exact_local-marketplace/` — ローカル専用プラグインのマーケットプレイス (`.claude-plugin/marketplace.json` + 各プラグイン)。`settings.json` の `extraKnownMarketplaces.local` + `enabledPlugins."<plugin>@local"` で有効化される。協調する複数 hook を 1 セットでバンドルしたい場合は単独 hook (`exact_hooks/`) ではなくこちらに切り出す。各プラグインの動作詳細は当該プラグイン直下の `README.md` に書く (公式マーケットプレイスの慣習に揃える)
- `exact_agents/`, `exact_skills/` — サブエージェント・スキル定義の置き場。
- `settings.json` — Claude Code 設定 (テンプレートが必要なため `.tmpl` 化されている)

`literal_CLAUDE.md` と paths なし `exact_rules/*.md` は機能的に同じ常時ロードで、役割で使い分ける:

- 横断メタ原則 (rule/skill 全体に効く、paths 付き rule の発火条件を前提にした指令など) → `literal_CLAUDE.md` (例: 新規ファイル作成プロトコル)
- 独立トピック (バグ修正、mise タスクなど、ファイル単位で分割したい規範・知識) → paths なし `exact_rules/*.md`

トピック粒度の rule は今後増えていく前提なので、`literal_CLAUDE.md` を肥大化させず横断メタだけに絞る。

自前運用パターンの参考: paths 付き rule (`claude-code-meta`) から大きめの docs (`claude-code-rules.md`、`skills.md`) を発火条件下で参照するペア構成。Claude Code rules/skills の機能仕様自体もこのペアに収めている (詳細は `~/.claude/docs/claude-code-rules.md`、`~/.claude/docs/skills.md`)。
