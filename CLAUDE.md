# 844196/dotfiles

## 概要

このコードベースは 844196 の dotfiles です。

- chezmoi を使用して管理します。
  - chezmoi 自体に関する知識は `/chezmoi` スキルをロードしてください。
- Linux (WSL2, devcontainer) および macOS で運用することを前提とします。
- XDG Base Directory Specification に可能な限り準拠させます。
- Zsh をデフォルトシェルとして使用します。
- mise をグローバルな言語・ツール管理に使用します。
- `apt` もしくは `brew` を使用しなければインストールすることができないツール群の管理は、このコードベースの対象外とします。
  - これらのツールについては、すでにインストールされていることを前提とします。

## 運用コマンド

- `chezmoi diff` - ソースとホームディレクトリの差分を表示します。

  ```bash
  chezmoi diff
  chezmoi diff --exclude scripts # 実行される予定の .chezmoiscripts ソースコードは除いた差分
  ```

- `chezmoi ls-scripts <next|all>` - `.chezmoiscripts` を実行される順番に表示します。

  ```bash
  chezmoi ls-scripts next # 次の apply 時に実行されるもの
  chezmoi ls-scripts all # 現在の状態にかかわらず全て
  ```

- `chezmoi apply` - ソースをホームディレクトリに適用します。

  ```bash
  chezmoi apply
  chezmoi apply --dry-run --verbose # ドライラン + 詳細表示
  ```

## ワークフロー

ソースを編集する場合は以下の順で進めます:

1. `files/` 以下のソースを編集する (ホームディレクトリ以下は直接編集しない)。
2. `chezmoi diff` で反映される差分を確認する。
3. ユーザーの同意を得てから `chezmoi apply` で反映する。
4. 反映後の挙動を確認する。
5. ユーザーが期待通り動いていることを確認してからコミットする。

## ディレクトリ・ファイルの役割

| パス | 役割 |
|---|---|
| `files/` | chezmoi ソースルート (chezmoi で `~/` に反映、詳細は [`./files/CLAUDE.md`](./files/CLAUDE.md)) |
| `packages/` | 自作ツールのソースコード (ビルドされて `~/` に配置、詳細は [`./packages/CLAUDE.md`](./packages/CLAUDE.md)) |
| `install.sh` | ブートストラップスクリプト |

## Git ワークフロー

- 変更はすべて `main` ブランチに直接コミットします。
- コミットメッセージのフォーマットは [Conventional Commits](https://www.conventionalcommits.org/) に従います。
  - 利用可能なタイプは `.versionrc` を参照してください (scope は未定義のため省略)。
