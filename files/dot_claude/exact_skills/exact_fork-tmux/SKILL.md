---
name: fork-tmux
description: 現在のセッションを tmux の新しいペインでフォークする。tmux 上で動作している場合に使用する。
---

# Fork session in tmux

現在のセッションを tmux の新しいペインでフォークする。

## 手順

以下のコマンドを実行する（セッションID `${CLAUDE_SESSION_ID}` を使用）:

```bash
tmux split-window -h -c "$PWD" "claude --resume ${CLAUDE_SESSION_ID} --fork-session --enable-auto-mode --allow-dangerously-skip-permissions"
```

コマンド実行後、「フォークした」とだけ報告する。
