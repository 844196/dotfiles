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

- `chezmoi diff` - ソースディレクトリとホームディレクトリの差分を表示します。
  - この差分には "次に `chezmoi apply` した時に実行される chezmoi ライフサイクルスクリプト" も含まれます。
- `chezmoi apply` - ソースディレクトリをホームディレクトリに適用します。

## ファイルツリー (抜粋)

```
files/                    # chezmoi ソースディレクトリ (.chezmoiroot で指定)
  .chezmoiscripts/
  Library/
  dot_cache/
  dot_claude/
  dot_config/
  dot_docker/
  dot_local/
  .chezmoiexternal.yaml
packages/                 # 自作ツール群 (詳細は packages/CLAUDE.md を参照)
install.sh                # ブートストラップスクリプト (devcontainer で使用)
```

## Git ワークフロー

- 変更はすべて `main` ブランチに直接コミットします。
- コミットメッセージのフォーマットは [Conventional Commits](https://www.conventionalcommits.org/) に従います。
  - 利用可能なタイプとスコープは `.versionrc` を参照してください。

## 補遺

- `apt` もしくは `brew` を使用しなければインストールすることができないツール群の管理は、このコードベースの対象外とします。
  - これらのツールについては、すでにインストールされていることを前提とします。
