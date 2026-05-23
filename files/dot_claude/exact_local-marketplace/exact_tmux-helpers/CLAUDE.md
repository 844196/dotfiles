# tmux Helpers

tmux 上で動作する Claude Code セッションを操作するスキル群。

## 構成要素

| 要素 | 役割 |
|---|---|
| [`fork-tmux` スキル](exact_skills/exact_fork-tmux/SKILL.md) | 現セッションを tmux の新しいペインで fork する (`claude-yolo --split-pane --resume --fork-session`) |

## 関連プラグイン

- [personal-scratchpad](../exact_personal-scratchpad/CLAUDE.md): `handover-tmux` スキルが同様に `claude-yolo --split-pane` を使うが、ハンドオーバー文書の作成を伴うため personal-scratchpad 側に置いている
