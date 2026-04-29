# Block Long Sleep

`PreToolUse:Bash` で実行される Bash コマンドを全箇所スキャンし、`sleep N[smhd]` が 25 秒以上ならブロックする hook。長尺の `sleep` でターンが詰まるのを防ぎ、適切な代替 (`CronCreate` / `run_in_background`) に誘導する。

## What It Does

| Hook | Event | Matcher | 動作 |
|---|---|---|---|
| `block-long-sleep.sh` | `PreToolUse` | `Bash` | `tool_input.command` 内の `sleep N[smhd]` を全箇所 grep。1 つでも 25 秒以上 (秒/分/時/日換算) なら `decision: "block"` で停止し、reason に代替手段を案内 |

ブロック時の reason: 「定期ポーリングには `CronCreate` ツール (`/loop` スキルから呼べる)、完了待ちには Bash ツールの `run_in_background` オプションを使用」。

## Why

Claude Code 本体にも類似のブロック機能が feature flag `tengu_amber_sentinel` 配下で段階的にロールアウト中 (v2.1.108〜)。有効時は先頭の `sleep N` (秒, 単位なし) が 25 秒以上でブロックされる。

このフックは本体機能を以下 3 点で補完する:

1. flag off 環境
2. 先頭以外の `sleep` (`foo && sleep 60` など)
3. `s`/`m`/`h`/`d` 単位付きの `sleep`

`tengu_amber_sentinel` が GA 化してカバー範囲が重なったらこのプラグインは削除候補。

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
    "block-long-sleep@local": true
  }
}
```
