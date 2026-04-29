# New File Protocol

`Write` ツール単体での新規ファイル作成を PreToolUse で deny し、`touch` → `Read` → `Write` の 3 ステップ作成プロトコルをエージェントに強制する hook。SessionStart で同プロトコルを `additionalContext` として事前告知することで、ノーヒントでの大量ブロック発生を抑える。

## What It Does

- **PreToolUse:Write (強制)**: `tool_input.file_path` の存在を確認し、未存在 (= 新規ファイル作成) なら `permissionDecision: "deny"` を返してエージェントに 3 ステップ作成手順を案内する。既存ファイルの上書きは Write が Read 経由を要求するためそのまま通す。
- **SessionStart (事前告知)**: セッション開始時に `hookSpecificOutput.additionalContext` として 3 ステップ作成手順を注入する。プラグインは `paths` 付き rule を提供できないため、`SessionStart` の `additionalContext` を「ルール相当の事前告知」として代替する。

## Why

Claude Code の `paths` 付き rule (`~/.claude/rules/*.md` または `<project>/.claude/rules/*.md`) は **Read ツール実行時にのみ評価される**。`Write` 単体で新規ファイルを作ると paths rule が発火せず、該当ファイル種別に紐づくガイドラインが取りこぼされる。

回避するには touch で空ファイルを先に作り、Read で発火させてから Write で内容を書く必要がある (空ファイルでも `path_glob_match` が発火することは v2.1.119 で確認済み)。

このプロトコルは元々 `~/.claude/CLAUDE.md` にテキストで記載していたが、CLAUDE.md の指示はエージェントが守らないことがあるため hook に格上げして強制する形にした。

## How It Works

| Hook | Event | Matcher | 動作 |
|---|---|---|---|
| `session-start.sh` | `SessionStart` | (なし: 全 source) | `additionalContext` で 3 ステップ手順を事前告知 |
| `pre-write.sh` | `PreToolUse` | `Write` | `tool_input.file_path` が存在しない場合のみ deny + reason |

サブエージェント / MCP 経由の Write も PreToolUse は発火するため一律にカバーされる。SessionStart は `startup` / `resume` / `clear` / `compact` のすべての source で発火させ、resume 時にも告知が再注入されるようにしている。

## Configuration

このプラグインを有効化するには、Claude Code の `settings.json` に以下を登録する:

```json
{
  "extraKnownMarketplaces": {
    "local": {
      "source": {
        "source": "directory",
        "path": "/path/to/local-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "new-file-protocol@local": true
  }
}
```

`Bash(touch *)` を `permissions.allow` に登録しておくと、deny → touch 実行で permission prompt が挟まらずスムーズ。

## References

- 着想: https://zenn.dev/metalels86/articles/2418a39f6057bb
