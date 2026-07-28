---
paths:
  - files/.chezmoiscripts/**
---

# chezmoiscripts の運用方針

`run_after_*` は主に以下の用途で使用する:

- サービスマネージャー (e.g. `systemd`) の制御
- この dotfiles 自身で管理しているツールマネージャー (e.g. mise) のインストール処理
- [自作ツール](diy-tools.md) のビルドと配置
- シェル起動時の負荷分散 (e.g. `bat` キャッシュの再生成)
  - 「chezmoi がなかったら zshrc に書いていたであろう」処理

## 番号の付け方

実行順序を表し、依存関係に応じて決める。飛び番は許容する。

## `run_after_*` は `chezmoi diff` に毎回「新規ファイル」として現れる

`run_after_*` は `run_onchange_*` と異なりソース内容のハッシュで実行要否を判定しないため、内容が変わっていなくても毎回実行対象になる。`chezmoi diff` はこれを反映し、`run_after_*` スクリプトを (実際の変更有無によらず) 常に "追加" 相当の diff hunk として表示する。

これは実行前提の既知の挙動であり、実際の設定変更を意味しない。`chezmoi diff` の結果を要約・報告する際は、`run_after_*` (`run_onchange_after_*` ではない方) に関する diff hunk を除外し、それ以外の差分だけを報告する。

ただし、`run_after_*` 自体を編集した直後は、その変更が `chezmoi diff` 上でこの既知のノイズと区別できない。この場合は `git diff` でソース側の変更を確認する。

## `run_onchange_*` のハッシュ判定とテンプレートの罠

`run_onchange_*` の「変更検出」はスクリプト**ソース内容**のハッシュで判定される。テンプレート展開後ではないので、外部データに連動して再実行させたいときはコメントでハッシュを埋め込んで自前でソースを変動させる。

```sh
#!/bin/bash
# dconf.ini hash: {{ include "dconf.ini" | sha256sum }}
dconf load / < {{ joinPath .chezmoi.sourceDir "dconf.ini" | quote }}
```

ただし監視対象が**それ自体テンプレート (`*.tmpl`) で [chezmoidata] 等を参照している**場合、`include` は生ソースを返すだけなのでデータ変更に追従しない。テンプレート展開後の文字列を hash したいときは `includeTemplate <path> .` を使う (第 2 引数 `.` で現在のデータスコープを渡す):

```sh
#!/bin/bash
# config.toml hash: {{ includeTemplate "dot_config/foo/config.toml.tmpl" . | sha256sum }}
```

これならテンプレートのリテラル変更でも参照データ ([chezmoidata] や [chezmoiconfig] の `data:` セクション) の変更でも展開結果が変われば hash が変わる。

[chezmoidata]: ../../files/.chezmoidata.json
[chezmoiconfig]: ../../files/.chezmoi.yaml.tmpl
