---
name: handover-tmux
description: 現在の会話をハンドオーバー文書にまとめ、新しい tmux ペインで Claude Code セッションを起動して引き継ぐ。
---

# Handover in a new tmux pane

現在の会話をハンドオーバー文書にまとめ、ファイルに書き出し、新しい tmux ペインで Claude Code セッションを起動して引き継ぐ。

## 手順

1. `/handover:handover` スキルでハンドオーバ文書を書き出す

2. 以下のコマンドを実行する

   ```bash
   claude-yolo --split-pane '/handover:takeover <手順1で書き出したハンドオーバ文書のパス>'
   ```

3. 「tmux の新ペインに引き継いだ」と報告する
