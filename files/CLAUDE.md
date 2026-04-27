# `~/` (`files/`)

## ルール

### ディレクトリには可能な限り `exact_` を付ける

付けないとソース上削除したファイルがホームディレクトリ以下に残り続けてしまうため、原則としてディレクトリには `exact_` を付ける。

ただし、動的にファイルが生成されるディレクトリは以下のように対応する:
- `exact_` を付けつつ `.chezmoiignore` で動的に生成されるファイルを除外する
  - 動的生成されるファイルが少ない・特定できる場合
  - e.g. `./dot_claude/exact_skills/` + `.chezmoiignore` (apm が管理・配置するスキルが `chezmoi diff` に出てこないように `.chezmoiignore` で除外)
- `exact_` を付けない
  - 動的生成されるファイルが多すぎる・特定できない、システムや他のツールも使用・参照している場合
  - e.g. `./dot_claude/`

### ツール・パッケージ・プラグインの管理方針

- 原則バージョンもしくはコミットハッシュで固定する。
- 可能な限り mise に寄せる
  - 例外
    - Claude Code スキル・プラグイン: apm で管理する
    - zsh プラグイン: 5つくらいしか使ってない、ころころ変わるプラグインマネージャーについていくつもりもない、`zwc` で最適化したいため `.chezmoiexternal.yaml` で管理する
- その他必要なもののみ `.chezmoiexternal.yaml` で管理する
  - `refreshPeriod` によるキャッシュ化や tarball 展開の恩恵を受けられないため「`.chezmoiscripts/run_after_foobar.sh` で `curl` でダウンロードして…」は避ける

## リンク

- [`.chezmoiscripts/` の運用方針](../.claude/rules/chezmoiscripts.md)
