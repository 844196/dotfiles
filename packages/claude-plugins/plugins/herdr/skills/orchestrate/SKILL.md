---
name: orchestrate
description: Herdr で子エージェントを立ち上げて作業を委任するときに使う。「Herdr で別のエージェントに任せて」のような指示で使う。
---

# Herdr でのオーケストレーション

あなたはこれから Herdr で子エージェントを立ち上げ、作業を委任する親エージェント (オーケストレーター) になる。

## 手順

0. (まだ読んでいない場合): `herdr` スキルと `herdr:gotcha` スキルをロードする

1. 自分の pane ID / agent name を控える:

   ```bash
   herdr pane current --current   # .result.pane.pane_id
   herdr agent list               # 自分の agent name があれば
   ```

2. `handover` スキルでタスク依頼文書を書き出す。通常の内容に加え、あなたの pane ID / agent name (target) を明記させる。

3. 子を起動し、`herdr agent prompt <child> "/herdr:delegate-receive <手順2で書き出した文書のパス>"` で引き継がせる。

4. 完了を待つ:
   - 単発 / 直列: 手順3のコマンドに `--wait --timeout <MS>` を付ける。
   - 並行: 全員に投げたあと `herdr agent wait <target> --until idle,done,blocked --timeout <MS>` を対象ごとに順に呼ぶ。あるいは手順2の通知に任せて自分のターンを終える。

5. 通知が来たら `herdr agent get <target>` / `herdr agent read <target> --source recent-unwrapped --lines 120` で確認する。`blocked` なら中身を読んで対応する。
