# `~/` (`files/`)

chezmoi のソースルートディレクトリ。このディレクトリ以下のファイルは `chezmoi apply` によってターゲットディレクトリ (`~/`) に展開される。

Nested `CLAUDE.md` は [`.chezmoiignore`](.chezmoiignore) によって除外される。

## ルール

### ディレクトリには可能な限り `exact_` を付ける

付けないとソース上削除したファイルがホームディレクトリ以下に残り続けてしまうため、原則としてディレクトリには `exact_` を付ける。

ただし、動的にファイルが生成されるディレクトリは以下のように対応する:
- `exact_` を付けつつ chezmoiignore で動的に生成されるファイルを除外する
  - 動的生成されるファイルが少ない・特定できる場合
- `exact_` を付けない
  - 動的生成されるファイルが多すぎる・特定できない、システムや他のツールも使用・参照している場合
  - e.g. `./dot_claude/`

### ツール・パッケージ・プラグインの管理方針

- [mise](dot_config/exact_mise/config.toml.tmpl)
  - グローバルで使いたい言語ランタイム、CLI ツール
- [apm](exact_dot_apm/apm.yml)
  - Claude Code スキル・プラグイン
- [`.chezmoiexternal.yaml`](.chezmoiexternal.yaml)
  - 先の2つで管理できないもの
  - zsh プラグイン

バージョンは必ずタグ、もしくはコミットハッシュで固定する。`latest` などの曖昧な指定はしない。

## リンク

- [`.chezmoiscripts/` の運用方針](../.claude/rules/chezmoiscripts.md)
