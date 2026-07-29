## プラグインの管理

[`vim.pack`](https://neovim.io/doc/user/pack/#vim.pack) を使う。

ダウンロードされてきたプラグインは `$XDG_DATA_HOME/nvim/site/pack/core/opt/` に配置される。

[`nvim-pack-lock.json`](./nvim-pack-lock.json) も Git 管理するが、

- `chezmoi apply` 後の nvim 起動時に更新される
- 作業中は頻繁にエントリーの追加・削除が発生する

以上の理由のため、コミット前に `chezmoi add ~/.config/nvim/nvim-pack-lock.json` してソースリポジトリに取り込むことにする。
