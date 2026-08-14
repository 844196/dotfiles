---
name: orchestrate
description: Herdr で子エージェントを立ち上げて作業を委任するときに使う。「Herdr で別のエージェントに任せて」のような指示で使う。
---

# Herdr でのオーケストレーション

あなたはこれから Herdr で子エージェントを立ち上げ、作業を委任する親エージェント (オーケストレーター) になる。

## 手順

0. (まだ読んでいない場合): `herdr` スキルと `herdr:gotcha` スキルをロードする。

1. あなたの pane ID を控える:

   ```bash
   herdr pane current --current # .result.pane.pane_id
   ```

2. `handover` スキルでタスク依頼文書を書き出す。
   - 通常の内容に加えて、あなたの pane ID (子があなたと通信するため) を含めること。
   - 作業内容に「親へ中間報告をする」というステップを必ず盛り込むこと。
     e.g. 調査と実装を依頼する場合: (1) 調査 (2) 中間報告 (3) 実装、のように差し込む。

3. 子を起動し、`herdr agent prompt <child> "/herdr:delegate-receive <手順2で書き出した文書のパス>"` で引き継がせる。

4. 完了を待つ

5. 通知が来たら `herdr agent get <child>` / `herdr agent read <child> --source recent-unwrapped --lines 120` で確認する。
   `blocked` なら中身を読んで対応する。
