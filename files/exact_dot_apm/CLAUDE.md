# `files/exact_dot_apm/` (`~/.apm/`)

このディレクトリは [microsoft/apm](https://github.com/microsoft/apm) (Agent Package Manager) の設定をホストする。`apm.yml` に列挙したパッケージが `~/.apm/apm_modules/` に取り込まれ、種別に応じて `~/.claude/skills/<name>/` などへ配置される。

配置先の `~/.claude/skills/` は chezmoi では管理しない (apm 専用領域)。自作スキル・エージェントは `files/dot_claude/exact_local-marketplace/` でローカルマーケットプレイス経由のプラグインとして配置するため、apm と chezmoi の配置先は重ならない。
