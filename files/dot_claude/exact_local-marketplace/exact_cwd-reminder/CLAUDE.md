# CWD Reminder

CWD が git リポジトリルートからズレている場合に `SessionStart` / `UserPromptSubmit` で `additionalContext` を注入し、エージェントに現在地を再告知する hook。

## What It Does

| Hook | Event | Matcher | 動作 |
|---|---|---|---|
| `cwd-reminder.sh` | `SessionStart` | (なし: 全 source) | input の `cwd` と `git rev-parse --show-toplevel` を比較し、ズレていたら `additionalContext` で警告 |
| `cwd-reminder.sh` | `UserPromptSubmit` | (なし) | 同上。ターンごとに発火するので、`cd` した後に CWD を忘れたケースを毎回リマインドできる |

git 配下にない CWD では何もしない (比較対象がないため)。

## Why

エージェントが Bash で `cd <subdir>` して作業した後、後続のターンでその事実を忘れて相対パスでコマンドを実行し、想定外の場所にファイルを作る・コマンドが失敗する等でワークフローが破綻するケースがある。

`UserPromptSubmit` はターンごとに発火するため、CWD がリポジトリルートとズレている限りエージェントには毎ターン現在地が再注入される。これにより「`cd` したことを忘れる」状況を構造的に防ぐ。

`SessionStart` は `resume` / `clear` / `compact` 直後にも発火するため、復帰時点で既に CWD がズレていればその時点で告知される。

`CwdChanged` は購読していない。Claude Code 2.1.123 では Bash tool の execution context に `agentId` が入っていると CwdChanged の dispatch がスキップされる仕様で (バイナリ解析で確認: dispatch ガード `if (c && !z && !c.backgroundTaskId)` 内の `z = preventCwdChanges = !$.agentId` 経路)、メインエージェントでも `$.agentId` が non-empty になる起動経路があり実機で発火しないため。`UserPromptSubmit` は次のユーザー発言時に必ず発火するので、Bash 直後の即時告知は諦めて代替する。

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
    "cwd-reminder@local": true
  }
}
```
