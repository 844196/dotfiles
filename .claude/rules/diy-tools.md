---
paths:
  - packages/tool-*/**
---

# `packages/tool-*/`

## 概要

このディレクトリには以下に該当する自作ツールのソースコードが配置されます。

- Bash/Zsh スクリプトでは複雑なもの
- なんらかのランタイムを必要とするが、プロジェクトによってランタイムが固定されており、スクリプトのシェバンを `#!/usr/bin/env -S <runtime>` とすると、意図しないランタイムで実行される可能性があるもの
- 独立したリポジトリにするほどではないもの

各自作ツールは、後述するディレクトリ配置と `install` タスクの定義に従ってさえいれば、ランタイム・ビルド方法・依存関係・ホームディレクトリ以下の配置に関しては自由に選択できるものとします。

## 基本的な自作ツールのディレクトリ配置

```
<repository-root>/
  packages/
    tool-*/
      mise.toml   # 使用ランタイムや install タスクの定義
```

## `install` タスク

各自作ツールの `mise.toml` には `install` タスクを定義します。`install` タスクはスクリプトもしくはバイナリをホームディレクトリ内の任意のパスに配置します。

一般的に `install` タスクには主に以下の内容が含まれますが、これらに限定されません:
- ランタイムのインストール
- 依存関係のインストール
- ビルド
- ビルド成果物のホームディレクトリ以下への配置
  - e.g. `~/.opt/dotfiles/opt/<tool-name>/bin`, `~/.opt/dotfiles/opt/<tool-name>/libexec`

各自作ツールの `install` タスクは `chezmoi apply` 中に [chezmoiscripts](chezmoiscripts.md) から `mise run //packages/...:install` で一括呼び出しされます。

### `bin/` を持つ package を追加するとき

次のファイル内にある `PATH` 環境変数定義を更新する必要があります:
- [`.zshenv`](../../files/exact_dot_zsh/dot_zshenv.tmpl)
- [`mise.toml`](../../files/dot_config/exact_mise/config.toml.tmpl)
