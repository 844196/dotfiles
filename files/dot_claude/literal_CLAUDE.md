# ~/.claude/CLAUDE.md

## 新規ファイル作成プロトコル

`Write` ツールで新規ファイルを作るとき、`paths` 付きの rule (`~/.claude/rules/*.md` または `<project>/.claude/rules/*.md`) は発火しないため、以下の 3 ステップに従う:

1. `Bash` で `touch <path>` (空ファイル作成)
2. `Read` で空ファイルを読む (paths 付き rule がここで発火、ガイドラインが注入される)
3. `Write` で実際の内容を書き込む

理由: Claude Code の `paths` フロントマターは Read ツールでのみ評価される (詳細: `~/.claude/docs/claude-code-rules.md`)。既存ファイルの編集 (`Read` → `Edit`、`Read` → `Write`) ではプロトコル不要。
