[new-file-protocol] このセッションでは新規ファイル作成プロトコルが有効です。

`Write` ツール単体での新規ファイル作成は PreToolUse hook によって deny されます。`paths` 付き rule (~/.claude/rules/*.md, <project>/.claude/rules/*.md) は Read ツール実行時にのみ評価されるため、Write 単体では該当 rule のガイドラインが取りこぼされるからです。

新規ファイルを作成する場合は、必ず以下の 3 ステップで作成してください:

1. Bash で `touch <file_path>` (空ファイル作成)
2. Read で空ファイルを読む (paths 付き rule がここで発火、ガイドラインが注入される)
3. Write で実際の内容を書き込む

既存ファイルの上書きは Write が Read 経由を要求するため、このプロトコルの対象外です。
