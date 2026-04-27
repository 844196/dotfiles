---
paths:
  - files/.chezmoiscripts/**
---

# `.chezmoiscripts/` の運用方針

`run_after_*` は主に以下の用途で使用する:

- サービスマネージャー (e.g. `systemd`) の制御
- この dotfiles 自身で管理しているツールマネージャー (e.g. mise) のインストール処理
- `packages/` 以下の自作ツールのビルドと配置
- シェル起動時の負荷分散 (e.g. `bat` キャッシュの再生成)
  - 「chezmoi がなかったら `.zshrc` に書いていたであろう」処理

## 番号の付け方

実行順序を表し、依存関係に応じて決める。飛び番は許容する。
