# apm

このディレクトリは [microsoft/apm](https://github.com/microsoft/apm) (Agent Package Manager) の設定をホストする。`apm.yml` に列挙したパッケージが `~/.apm/apm_modules/` に取り込まれ、種別に応じて `~/.claude/skills/<name>/` などへ配置される (実配置先は `~/.apm/apm.lock.yaml` の `deployed_files` を参照)。

apm install は `files/.chezmoiscripts/run_onchange_after_12-apm-install.sh.tmpl` 経由で `apm.yml` のハッシュが変わったときに走る。

## `apm.yml` を編集するときの規律

apm が `~/.claude/skills/` に配置するスキルは、`files/dot_claude/exact_skills/.chezmoiignore` で chezmoi の視界から外している。`exact_skills/` は chezmoi が掌握しているため、ignore に列挙されていない apm 配置は次回 apply で削除されてしまう。

そのため `apm.yml` にスキル系パッケージを追加・削除したら、`files/dot_claude/exact_skills/.chezmoiignore` を同じコミットで更新する。記載するのは「`~/.claude/skills/` 配下に出来るディレクトリ名」であり、`apm.yml` の URL 末尾とは一致しないことがある (例: `claude-plugins-official/plugins/claude-md-management` は `claude-md-improver` を配置する)。実配置名は `~/.apm/apm.lock.yaml` の `deployed_files` で確認する。

同期忘れは `mise run //:diff` で「apm 配置スキルを削除しようとする差分」として可視化されるので、apply 前に気付ける。
