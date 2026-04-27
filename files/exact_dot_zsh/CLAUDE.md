# `files/exact_dot_zsh/` (`~/.zsh/`)

このディレクトリは「XDG Base Directory に従うと Package by Layer になって凝集度が低くなる」問題を解決するために `.zsh*` 系および自作関数・プラグインを配置する場所です。

以下については `$XDG_CACHE_HOME/zsh/` および `$XDG_STATE_HOME/zsh/` に配置されます (括弧書きは XDG Base Directory 仕様より):
- キャッシュ (非必須)
- 状態ファイル (再起動後も保持されるべきだが、重要ではない or ポータビリティが低い)
