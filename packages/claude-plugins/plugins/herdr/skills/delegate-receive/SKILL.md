---
name: delegate-receive
description: Herdr 経由で親エージェントから作業を委任されたときに使う。委任文書を読んで作業を進め、完了したら親へ報告する。
arguments:
  - HANDOVER_PATH
---

# Herdr での委任を受ける

あなたは Herdr 経由で親エージェントから作業を委任された。

## 手順

1. $HANDOVER_PATH を読む。タスクと親の target (pane ID / agent name) を把握する。
2. タスクを実行する。判断に迷った場合は、手順3と同じ経路で親に確認する。人間への `AskUserQuestion` は使わない（応答できる人間がいない）。
3. 完了したら報告を一時ファイル (例: /tmp/report-*.txt) に書き、`herdr agent prompt <親の target> "$(cat /tmp/report-*.txt)"` で送信する。本文をダブルクォートへ直接埋め込まない。
