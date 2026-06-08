---
name: handover-tmux
description: 現セッションの内容を整理・文書化してファイルへ書き出し、新しく tmux で立ち上げる Claude Code セッションに作業を引き継ぐ。
---

# Handover in a new tmux pane

現セッションの内容を整理・文書化してファイルへ書き出し、新しく tmux で立ち上げる Claude Code セッションに作業を引き継ぐ。

## 手順

手順 1〜3 は **一気通貫で実行する**。途中で停止しないこと。

1. `/handover:handover` スキルでハンドオーバ文書を書き出す

   サブスキルから戻ってきても、それはこのスキルの完了ではない。**即座に手順 2 へ進む**。

2. 以下のコマンドを実行する

   ```bash
   tmux split-window -h -c "$PWD" -t $TMUX_PANE "${user_config.CLAUDE_COMMAND} '/handover:takeover <手順1で書き出したハンドオーバ文書のパス>'"
   ```

3. 「引き継いだ」とだけ報告する
