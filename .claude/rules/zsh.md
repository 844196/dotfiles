---
description: zsh の動作はリポジトリ全体に分散している。zsh が絡む変更時は同期点に注意し、必要に応じて全体地図を参照する
---

# zsh の構成と同期点

zsh の挙動は `files/dot_config/exact_zsh/` だけでは完結せず、`packages/`、`files/exact_dot_844196/`、`files/.chezmoiexternal.yaml`、`files/.chezmoiscripts/`、`files/dot_apm/`、`files/dot_claude/` および ターゲット側の `~/.844196/`, `~/.local/share/zsh/`, `~/.cache/zsh/` 等の組み合わせ結果として成立する。片方だけ修正してもう片方が追従していない型のバグが起きやすい。

## 代表的な同期点

以下は「片方変えたらもう片方が連動するはず」という対応関係。これらに該当する変更時は両側の整合を確認する。

- **PATH に乗るスクリプト** — `packages/<tool>/mise.toml` の `build`/`install` ↔ `~/.844196/{bin,libexec}` 配置 ↔ 旧 `~/.local/{bin,libexec}` を参照する箇所が残っていないか
- **apm 経由のスキル/プラグイン** — `files/dot_apm/apm.yml` ↔ `files/dot_claude/exact_skills/.chezmoiignore` (詳細: `.claude/rules/dot-apm.md`)。zsh 起動時の補完・関数読み込みパスにも波及する場合あり
- **動的生成物の chezmoi 取り込み** — `.zcompdump`, `history`, `compinit` キャッシュ等は ターゲット側で動的生成される。配置先ディレクトリの `exact_` 判断 ↔ `.chezmoiignore` の追従 (詳細: `docs/chezmoi-layout.md` の「`exact_` を付けるか外すか」)
- **external プラグイン** — `files/.chezmoiexternal.yaml` のコミットハッシュ/タグ pin ↔ `dot_zshrc` 側の `autoload`/`source` パス ↔ プラグイン提供 widget の `bindkey` 配線
- **統合環境分岐** — `dot_zshrc` 冒頭の `VSCODE_WORKSPACE` / `VSCODE_COPILOT_TERMINAL` / `REMOTE_CONTAINERS` / `NO_TMUX` / `TMUX` 判定 ↔ 各環境を提供する側 (devcontainer 設定, VSCode 設定, tmux 起動条件) ↔ `files/dot_claude/settings.json` の SessionStart 等で立つ環境
- **mise の有効化** — `dot_zshrc` の `mise activate zsh` (interactive shell 用) ↔ `dot_zshenv` の `$XDG_DATA_HOME/mise/shims` PATH 注入 (全シェル用) ↔ `files/dot_claude/settings.json` の SessionStart hook ↔ `mise.toml` の env / tools ↔ `files/.chezmoiscripts/run_after_08-setup-mise.sh`
- **commit/PR まわりの bin** — `files/exact_dot_844196/exact_bin/git-claude-*` ↔ `files/dot_claude/skills/exact_commit*/`, `exact_pr/` ↔ `files/dot_claude/settings.json` の `attribution` / `includeGitInstructions` (詳細: `.claude/rules/editing-commit-pr-files.md`, `docs/include-git-instructions.md`)

## 全体地図

起動シーケンス、機能別 (プロンプト / autoload 関数 / zle・キーバインド / 補完 / PATH / 統合分岐 / 履歴・state)、取り込み方針 (external / apm / mise / packages の使い分け) の詳細地図は `docs/zsh-architecture.md` を参照。
