# `files/exact_dot_apm/` (`~/.apm/`)

このディレクトリは [microsoft/apm](https://github.com/microsoft/apm) (Agent Package Manager) の設定をホストする。`apm.yml` に列挙したパッケージが `~/.apm/apm_modules/` に取り込まれ、種別に応じて `~/.claude/skills/<name>/` などへ配置される。

配置先の一つである `~/.claude/skills/` は chezmoi 側では `files/dot_claude/exact_skills/` で `exact_` プレフィックス付きディレクトリのため、パッケージの追加・削除を行う際は `files/dot_claude/exact_skills/.chezmoiignore` を同時に更新すること。
