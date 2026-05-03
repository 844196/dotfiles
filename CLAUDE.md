# 844196/dotfiles

## 概要

このコードベースは 844196 の dotfiles です。

- chezmoi を使用して管理します。
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

ソース (`files/`, `packages/`) を編集する場合は以下の順で進めます:

1. ソースを編集する。
2. 反映される差分を確認する。
3. 反映する。
4. 反映後の挙動を確認する。
5. ユーザーが期待通り動いていることを確認してからコミットする。

**永続化を意図した変更のために chezmoi ターゲットにあたる `~/` 以下のファイルを直接編集することは禁止します。**

### 例外: 一時的な調査・デバッグ

ユーザーが明示的にその意図を伝えた場合のみ、一時的な調査やデバッグの目的のために `~/` 側のファイルを直接編集してよい。

作業が終わったら必ず `files/` 側に正式な変更を反映し、`~/` 側の一時編集は捨てる (`chezmoi apply` で上書きされて消えるものは放置、非 `exact_` ディレクトリ内のものは手動で削除する)。

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
