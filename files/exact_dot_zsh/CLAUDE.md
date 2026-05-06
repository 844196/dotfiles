# `files/exact_dot_zsh/` (`~/.zsh/`)

このディレクトリは「XDG Base Directory に従うと Package by Layer になって凝集度が低くなる」問題を解決するために `.zsh*` 系および自作関数を配置する場所です。

ただし、以下のファイルは別のパスに配置されます:
- 履歴 - `$XDG_DATA_HOME/zsh/history`
- 補完系ダンプ・キャッシュファイル - `$XDG_CACHE_HOME/zsh/comp*`
- プラグイン - `$XDG_DATA_HOME/<plugin-name>/`
- 自作ツール以外の補完関数 - `$XDG_DATA_HOME/zsh/site-functions/_<command-name>`

また、起動高速化のため一部のコードスニペットは `chezmoi apply` 時に chezmoiscripts によってキャッシュが生成され、zshrc から参照されます。
