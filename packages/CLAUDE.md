# `packages/`

## 概要

このディレクトリには以下に該当する自作ツールのソースコードが配置されます。

- Bash/Zsh スクリプトでは複雑なもの
- なんらかのランタイムを必要とするが、プロジェクトによってランタイムが固定されており、スクリプトのシェバンを `#!/usr/bin/env -S <runtime>` とすると、意図しないランタイムで実行される可能性があるもの
- 独立したリポジトリにするほどではないもの

各自作ツールは、後述するディレクトリ配置と `build` / `install` タスクの定義に従ってさえいれば、ランタイム・ビルド方法・依存関係・ホームディレクトリ以下の配置に関しては自由に選択できるものとします。

## 基本的な自作ツールのディレクトリ配置

```
<repository-root>/
  packages/
    CLAUDE.md     # このファイル
    <tool-name>/
      src/        # ソースコード
      mise.toml   # 使用ランタイムや "build" / "install" タスクの定義
```

## `install` タスク

各自作ツールの `mise.toml` には `build` / `install` タスクを定義します。`install` は `build` に依存し、ビルド成果物を per-package ディレクトリ `~/.opt/dotfiles/opt/<tool-name>/bin/<bin-name>` または `~/.opt/dotfiles/opt/<tool-name>/libexec/<bin-name>` に配置します。`install` タスクには主に以下の内容が含まれますが、これらに限定されません:

- ランタイムのインストール
- 依存関係のインストール
- ビルド
- ビルド成果物のホームディレクトリ以下への配置
  - e.g. `~/.opt/dotfiles/opt/<tool-name>/bin`, `~/.opt/dotfiles/opt/<tool-name>/libexec`

各自作ツールの `install` タスクは `chezmoi apply` 後に `files/.chezmoiscripts/run_after_10-install-dotfiles-packages.sh.tmpl` から `mise run //packages/...:install` で一括呼び出しされます。個別ツールの動作確認時は `mise run //packages/<tool-name>:install` を直接実行できます。

### `bin/` を持つ package を追加するとき

次のファイルに `~/.opt/dotfiles/opt/<tool-name>/bin` を追記する必要があります:
- [`.zshenv`](../files/exact_dot_zsh/dot_zshenv.tmpl)
- [`mise.toml`](../files/dot_config/exact_mise/config.toml.tmpl)
