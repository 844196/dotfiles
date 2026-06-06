---
name: handover-tmux
description: 現セッションの内容を整理・文書化してファイルへ書き出し、新しく tmux で立ち上げる Claude Code セッションに作業を引き継ぐ。
---

# Handover in a new tmux pane

現セッションの内容を整理・文書化してファイルへ書き出し、新しく tmux で立ち上げる Claude Code セッションに作業を引き継ぐ。

## 手順

1. `/handover:handover` スキルでハンドオーバ文書を書き出す

2. 以下のコマンドを実行する

   ```bash
   tmux split-window -h -c "$PWD" -t $TMUX_PANE "${user_config.CLAUDE_COMMAND} '/handover:takeover <手順1で書き出したハンドオーバ文書のパス>'"
   ```

3. 「引き継いだ」とだけ報告する
