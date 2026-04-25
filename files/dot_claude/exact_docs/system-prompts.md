# システムプロンプト集

Claude Code CLI から抽出されたシステムプロンプト・ツール説明・組み込みスキルの一式。`Piebald-AI/claude-code-system-prompts` のリリース tarball を解凍したものが配置されている。

## 配置

`~/.local/share/claude-code-system-prompts/`

主要な構造:

- `system-prompts/` — プロンプト本体 (約 280 ファイル)
- `CHANGELOG.md` — バージョンごとの変更点
- `tools/` — Piebald-AI 側の補助スクリプト

## ファイル命名

`system-prompts/` 配下のファイル名プレフィックスで種類が分かれる:

| プレフィックス | 内容 |
|---|---|
| `system-prompt-*` | メインシステムプロンプトの構成要素 |
| `system-reminder-*` | `<system-reminder>` で挿入されるリマインダ |
| `tool-description-*` | 各ツールの説明文 (Bash, Read, Write 等) |
| `agent-prompt-*` | 各エージェント (Explore, Plan mode 等) のプロンプト |
| `skill-*` | 組み込みスキル |
| `data-*` | 参照データ (Anthropic API リファレンス、モデルカタログ等) |

## 想定される使い方

- CLAUDE.md / rule / skill 設計時に、既存指令と重複していないか確認する
- `includeGitInstructions: false` 等のフラグで読み込まれなくなる指令の特定 (該当ファイルはたとえば `tool-description-bash-git-commit-and-pr-creation-instructions.md` のように命名されている)
- バージョン更新時の挙動差分の確認 (`CHANGELOG.md` を使う。tarball 展開なので `.git` は無く、`git log` / `git diff` は使えない)
