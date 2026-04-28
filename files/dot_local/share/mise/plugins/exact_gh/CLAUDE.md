# `files/dot_local/share/mise/plugins/exact_gh/` (`~/.local/share/mise/plugins/gh/`)

GitHub CLI は本来 `$XDG_STATE_HOME` に格納されるべき "アクティブなアカウント情報" をデフォルトでは `${XDG_CONFIG_HOME:-$HOME/.config}/gh/` に格納します。このため、マルチアカウント運用、および、chezmoi の `exact_` と相性が悪い問題があります。

この mise プラグインは、アカウント切り替えに必要な `$GH_CONFIG_DIR` と `$GH_HOST` 環境変数を自動的に算出・エクスポートすることで、プロジェクトごとの GitHub CLI アカウント切り替えを実現します。

## Known Issues

GitHub CLI 自体の設定 (e.g. エイリアス) は `$GH_CONFIG_DIR/config.yml` に格納されます。本来であれば "設定はアカウント共通、認証情報だけを切り替え" できるべきですが、そもそも XDG Base Directory に従わない GitHub が悪いのと、困ってないので放置します。

## Configuration

### github.com

```toml
# mise.local.toml

[env]
_.gh = { user = "844196" }
```

```console
% export | grep '^GH_'
GH_CONFIG_DIR=/home/m-takeda/.local/state/gh/github.com/844196
GH_HOST=github.com

% gh auth login --web
...

% gh auth status
github.com
  ✓ Logged in to github.com account 844196 (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo'

% gh auth token
gho_************************************
```

### GitHub Enterprise

```toml
# mise.local.toml

[env]
_.gh = { user = "john.doe", host = "github.example.com" }
```

```console
% export | grep '^GH_'
GH_CONFIG_DIR=/home/m-takeda/.local/state/gh/github.example.com/john.doe
GH_HOST=github.example.com
```
