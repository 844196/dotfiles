# 844196/dotfiles

## 概要

このコードベースは 844196 の dotfiles です。

- chezmoi を使用して管理します。
- Linux (WSL2, devcontainer) および macOS で運用することを前提とします。
- XDG Base Directory Specification に可能な限り準拠させます。
- Zsh をデフォルトシェルとして使用します。
  - Zsh プラグインの管理には `.chezmoiexternal.yaml` を使用します。
- mise をグローバルなツールの管理に使用します。

## コマンド

- `mise run //:diff` - ソースとホームディレクトリの差分を表示します (`chezmoi diff --exclude scripts` のラッパー、ライフサイクルスクリプトの差分を除く)。
- `mise run //:apply` - ソースをホームディレクトリに適用します (`GITHUB_TOKEN=$(gh auth token) chezmoi apply` のラッパー)。

生の `chezmoi apply` は `files/.chezmoiscripts/run_after_08-setup-mise.sh` 経由で GitHub API を大量に呼び、`GITHUB_TOKEN` なしでは即座にレートリミットに到達します。このため `.claude/settings.json` で生の `chezmoi apply` は `deny`、`mise run //:apply` は `ask` に登録されています。

## ディレクトリの役割と権限

リポジトリは 3 層構造で、それぞれ役割と編集方針が異なります。

| パス | 役割 | エージェントの編集 |
|---|---|---|
| `files/` | chezmoi ソース (apply で `~/` に反映) | 自由 |
| `packages/` | 自作ツールのソースコード (ビルドされて `~/` に配置、詳細は `packages/CLAUDE.md`) | 自由 |
| `.agents/` | エージェントのワーキングメモ (`.gitignore` 済み、git 管理外) | 自由 (コミット不要) |
| `CLAUDE.md`, `README.md`, `LICENSE.md`, `mise.toml`, `lefthook.yaml`, `.versionrc`, `.editorconfig`, `.gitattributes`, `.gitignore`, `.ignore` | プロジェクトメタ | 編集可 (普段は触らない) |
| `install.sh`, `Dockerfile`, `compose.yaml`, `mise.local.toml` | bootstrap / デバッグ環境 | ユーザー指示時のみ |
| `wk.bindings.yaml` | 独自 which-key バインド | ユーザー指示時のみ (他の変更のついでに触らない) |

`files/` の内部構造・プレフィックス・テンプレート・`.chezmoiscripts/`・`.chezmoiexternal.yaml` の詳細は `docs/chezmoi-layout.md` を参照してください。

## Git ワークフロー

- 変更はすべて `main` ブランチに直接コミットします。
- コミットメッセージのフォーマットは [Conventional Commits](https://www.conventionalcommits.org/) に従います。
  - 利用可能なタイプは `.versionrc` を参照してください (scope は未定義のため省略)。

## 運用ワークフロー

ソースを編集する場合は、以下の順で進めます:

1. `files/` 以下のソースを編集する (ターゲット `~/` は直接編集しない)
2. `mise run //:diff` で `~/` への反映差分を確認する
3. `mise run //:apply` で `~/` に反映する
4. 反映後の挙動を確認する
5. ユーザーが期待通り動いていることを確認してからコミットする

- `mise run //:apply` は `.claude/settings.json` の `permissions.ask` に登録済み。エージェントが発火し、ユーザーの確認を経て実行されます。
- エージェントは自発的にコミットしません。コミットはユーザーの明示的な指示を受けてから実行します。
- 詳細な規範は `.claude/rules/chezmoi-source-editing.md` を参照してください。

## 補遺

- `apt` もしくは `brew` を使用しなければインストールすることができないツール群の管理は、このコードベースの対象外とします。
  - これらのツールについては、すでにインストールされていることを前提とします。
