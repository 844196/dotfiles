# 844196/dotfiles

Linux (WSL2) および macOS で運用する dotfiles です。[Chezmoi](https://www.chezmoi.io/) を使用して管理します。

`apt` もしくは `brew` を使用しなければインストールすることができないツール群の管理は、このコードベースの対象外とします。これらのツールについては、すでにインストールされていることを前提とします。

## 構成

- [`files/`](files/CLAUDE.md) - Chezmoi のソースルート ([`.chezmoiroot`](.chezmoiroot) によって設定)。

  このディレクトリ以下のファイルは `chezmoi apply` によってターゲット (`~/`) に展開されます。

- [`packages/tool-*/`](.claude/rules/diy-tools.md) - 自作ツールのソースコード。

  「シェルスクリプトで実装すると複雑になるので、TypeScript などで書いてビルドして配置したいが、独立したリポジトリにするほどではない自作ツール」のソースコードを配置します。`chezmoi apply` 時に chezmoiscripts によってビルドされ、ホームディレクトリ以下に配置されます。

## 運用コマンド

- `chezmoi diff` - ソースとホームディレクトリの差分を表示します。

  ```bash
  chezmoi diff
  chezmoi diff --exclude scripts # 実行される予定の chezmoiscripts ソースコードは除いた差分
  ```

- `chezmoi ls-scripts <next|all>` - chezmoiscripts を実行される順番に表示します。

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

1. ソースを編集する。
2. 反映される差分を確認する。
3. 反映する。
4. 反映後の挙動を確認する。
5. ユーザーが期待通り動いていることを確認してからコミットする。
   - 変更はすべて `main` ブランチに直接コミットする。
   - コミットメッセージのフォーマットは Conventional Commits に従う。コミットタイプは [`.versionrc`](.versionrc) を参照のこと。
