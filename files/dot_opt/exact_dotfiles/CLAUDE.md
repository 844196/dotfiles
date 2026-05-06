# `~/.opt/dotfiles/`

このディレクトリは「`~/.local/bin` は well-known なため `exact_` をつけることが出来ない」問題を回避するためのスクリプト置き場。

- `./exact_bin/` - `~/.local/bin/` 相当
- `./exact_libexec/` - `~/.local/libexec/` (システムであれば `/usr/local/libexec/`) 相当
- `./opt/<package>/` - `packages/<package>` のビルド成果物配置先 (`<package>/bin/<bin-name>` または `<package>/libexec/<bin-name>`)

`./opt/` は `packages/tool-*:install` タスクが動的に書き込むため `exact_` を付けない。空ディレクトリを保持するため `./opt/.keep` を置く。
