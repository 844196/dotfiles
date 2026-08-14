---
name: delegate-receive
description: Herdr 経由で親エージェントから作業を委任されたときに使う。
arguments:
  - HANDOVER_PATH
---

# Herdr での委任を受ける

あなたは Herdr 経由で親エージェントから作業を委任された。

## やること

1. `herdr` スキルと `herdr:gotcha` スキルをロードする。
2. $HANDOVER_PATH を読む。タスクと親の pane ID を把握する。
3. タスクを実行する。判断に迷った場合は親に確認する。
4. 完了したら親に報告する。

## Notice

進捗・完了報告は Herdr で親のペインへ直接行うこと。親はあなたの出力を常時監視していない。
