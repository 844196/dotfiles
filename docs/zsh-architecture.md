# zsh 構成の全体地図

zsh の挙動はリポジトリの複数層に分散しており、片方だけ変更してもう片方が追従していない型のバグが起きやすい。本ドキュメントは zsh 視点で「どこに何があるか」「実行時に何が起きるか」「片方変えたら何が連動するか」を一望するための地図。

編集前のチェックリスト的役割は `.claude/rules/zsh.md` を参照。本ドキュメントは深掘りリファレンス。

## 1. ライフサイクル概略

> TODO: zshenv → zshrc → compinit / mise hook / プラグインロード / autoload / 統合環境分岐 (VSCode・tmux・devcontainer・copilot) の起動順序を 1 本のフローとして記述する。
>
> - `~/.zshenv` (実体は `~/.zsh/.zshenv`、ソース: `files/symlink_dot_zshenv` + `files/exact_dot_zsh/dot_zshenv`)
> - `~/.zsh/.zshrc` (ソース: `files/exact_dot_zsh/dot_zshrc`)
> - chezmoi ライフサイクルスクリプト (`files/.chezmoiscripts/run_after_06-compile-zsh-files.sh`, `run_after_05-clear-compdump.sh` 等) の関与

## 2. 機能別マップ

各節で「ソース (どこに書かれているか) / ランタイム (どこで何が起きるか) / 依存先」を記述する。

### 2.1 プロンプト

> TODO: `prompt zen` の選択理由、`precmd` hook (`send-osc7` 等)、統合環境ごとのカスタマイズ (`zstyle ':prompt:zen:user'` の `bg`/`fg`/`format`) の関係。

### 2.2 autoload 関数

> TODO: `autoload -Uz` 群 (compinit, select-word-style, smart-insert-last-word, {up,down}-line-or-beginning-search, zman, anyframe-init, ...) と、`$ZDOTDIR/functions/**/*` (`~/.zsh/functions/**/*`) の自作関数の関係。配置元 (external / apm / mise / packages / 自作) の対応も。

### 2.3 zle とキーバインド

> TODO: widget の提供元 (anyframe, fast-syntax-highlighting, zsh-autosuggestions, 自作), `bindkey` 配線、Home/End/Delete などの基本キー、isearch 派生など。

### 2.4 補完

> TODO: `compinit` の起動位置、`$ZDOTDIR/vendor-completions/` (`~/.zsh/vendor-completions/`、external で配置), mise/apm/packages 経由の補完、`exact_` 判断と `.zcompdump` の扱い。

### 2.5 PATH と外部スクリプト

> TODO: `~/.844196/bin`, `~/.844196/libexec`, mise shim の優先順位。`packages/<tool>/mise.toml` の `install` がどこに配置するか。`~/.local/bin` 等の旧パスの扱い。

### 2.6 統合環境分岐

> TODO: `dot_zshrc` 冒頭の `VSCODE_WORKSPACE` / `VSCODE_COPILOT_TERMINAL` / `REMOTE_CONTAINERS` / `NO_TMUX` / `TMUX` / `ZSH_SCRIPT` / `ZSH_EXECUTION_STRING` 判定の意味と、各環境を立てる側 (devcontainer, VSCode 設定, tmux 起動条件) の対応。

### 2.7 履歴・state

> TODO: `~/.cache/zsh`, `~/.local/state/zsh` の役割、history の保存先と共有、chezmoi 管理外であること。

## 3. 同期点マトリクス

> TODO: `.claude/rules/zsh.md` の「代表的な同期点」を表形式で詳細化。各同期点について「変更箇所 / 連動箇所 / 検出方法 (`mise run //:diff` で見える差分パターン等) / 過去事例のコミットハッシュ」を記述。

## 4. 取り込み方針 (external / apm / mise / packages)

> TODO: `chezmoi-source-editing.md` の優先順位 (mise > apm > .chezmoiexternal.yaml) を zsh 視点で具体例付きに展開する。zsh プラグインがコミットハッシュ pin される理由、補完単一ファイルの取り込み先、自作スクリプトを `packages/` に置く判断基準など。

## 関連

- リポジトリ全体像と編集権限: `CLAUDE.md`
- chezmoi の構造と運用: `docs/chezmoi-layout.md`, `.claude/rules/chezmoi-source-editing.md`
- packages の規約: `packages/CLAUDE.md`
- apm スキルと chezmoiignore の同期: `.claude/rules/dot-apm.md`
- commit/PR 周りの bin: `.claude/rules/editing-commit-pr-files.md`, `docs/include-git-instructions.md`
