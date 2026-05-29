# New File Protocol

`Write` ツール単体での新規ファイル作成を PreToolUse で deny し、`touch` → `Read` → `Write` の 3 ステップ作成プロトコルをエージェントに強制する hook。SessionStart で同プロトコルを事前告知することで、ノーヒントでの大量ブロック発生を抑える。

## What It Does

- **PreToolUse:Write (強制)**: `tool_input.file_path` の存在を確認し、未存在 (= 新規ファイル作成) なら `permissionDecision: "deny"` を返してエージェントに 3 ステップ作成手順を案内する。既存ファイルの上書きは Write が Read 経由を要求するためそのまま通す。
- **SessionStart (事前告知)**: セッション開始時に 3 ステップ作成手順を注入する。プラグインは rule を提供できないため、`SessionStart` の出力を「ルール相当の事前告知」として代替する。

## Why

Claude Code の `paths` 付き rule (`~/.claude/rules/*.md` または `<project>/.claude/rules/*.md`) は **Read ツール実行時にのみ評価される**。`Write` 単体で新規ファイルを作ると paths rule が発火せず、該当ファイル種別に紐づくガイドラインが取りこぼされる。

回避するには touch で空ファイルを先に作り、Read で発火させてから Write で内容を書く必要がある (空ファイルでも `path_glob_match` が発火することは v2.1.119 で確認済み)。

このプロトコルは元々 `~/.claude/CLAUDE.md` にテキストで記載していたが、CLAUDE.md の指示はエージェントが守らないことがあるため hook に格上げして強制する形にした。

## How It Works

| Hook | Event | Matcher | 動作 |
|---|---|---|---|
| [`exact_rules/session-start.md`](exact_rules/session-start.md) | `SessionStart` | (なし: 全 source) | 3 ステップ手順を注入 |
| [`pre-write.sh`](exact_hooks/executable_pre-write.sh) | `PreToolUse` | `Write` | `tool_input.file_path` が存在しない場合のみ deny + reason |

サブエージェント / MCP 経由の Write も PreToolUse は発火するため一律にカバーされる。SessionStart は `startup` / `resume` / `clear` / `compact` のすべての source で発火させ、resume 時にも告知が再注入されるようにしている。

## References

- 着想: https://zenn.dev/metalels86/articles/2418a39f6057bb
