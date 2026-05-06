---
paths:
  - files/.chezmoiscripts/**
---

# `files/.chezmoiscripts/` の運用方針

`run_after_*` は主に以下の用途で使用する:

- サービスマネージャー (e.g. `systemd`) の制御
- この dotfiles 自身で管理しているツールマネージャー (e.g. mise) のインストール処理
- `packages/tool-*/` 以下の自作ツールのビルドと配置
- シェル起動時の負荷分散 (e.g. `bat` キャッシュの再生成)
  - 「chezmoi がなかったら `.zshrc` に書いていたであろう」処理

## 番号の付け方

実行順序を表し、依存関係に応じて決める。飛び番は許容する。

## `run_onchange_*` のハッシュ判定とテンプレートの罠

`run_onchange_*` の「変更検出」はスクリプト**ソース内容**のハッシュで判定される。テンプレート展開後ではないので、外部データに連動して再実行させたいときはコメントでハッシュを埋め込んで自前でソースを変動させる。

```sh
#!/bin/bash
# dconf.ini hash: {{ include "dconf.ini" | sha256sum }}
dconf load / < {{ joinPath .chezmoi.sourceDir "dconf.ini" | quote }}
```

ただし監視対象が**それ自体テンプレート (`*.tmpl`) で `.chezmoidata` 等を参照している**場合、`include` は生ソースを返すだけなのでデータ変更に追従しない。テンプレート展開後の文字列を hash したいときは `includeTemplate <path> .` を使う (第 2 引数 `.` で現在のデータスコープを渡す):

```sh
#!/bin/bash
# config.toml hash: {{ includeTemplate "dot_config/foo/config.toml.tmpl" . | sha256sum }}
```

これならテンプレートのリテラル変更でも参照データ (`.chezmoidata/*` や `.chezmoi.yaml.tmpl` の `data:`) の変更でも展開結果が変われば hash が変わる。
