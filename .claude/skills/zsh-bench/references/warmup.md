# 正典コマンドの warmup 構造

正典の bench コマンド:

```bash
zsh -ic exit && MISE_HOOK_ENV_CACHE_TTL=600s ZSH_BENCH=1 NO_TMUX=1 ~/.zsh/zsh-bench/zsh-bench --iters 32
```

この 1 ライナーには 2 つの「お膳立て」が入っている: `zsh -ic exit` (compdump warmup) と `MISE_HOOK_ENV_CACHE_TTL=600s` (mise hook-env fast-path 強制)。`--iters 32` の意図は SKILL.md `iter 数の選び方` を参照。前後比較するときはこのコマンドラインを丸ごと再現する。

## なぜ `zsh -ic exit` で compdump warmup が要るか

このリポジトリの `files/.chezmoiscripts/` は **シェル起動時の負荷分散** を担っており、`chezmoi apply` のたびに各種キャッシュが破棄・再生成される。代表的なもの:

- `run_after_08-clear-compdump.sh` — `~/.cache/zsh/compdump*` を **毎 apply で削除**。次回 zsh 起動時に `compinit` が compdump を再生成するため、apply 直後の初回起動は `compinit` / `compdump` が重く出る (`first_command_lag_ms` / `first_prompt_lag_ms` に直撃)
- `run_onchange_after_09-compile-zsh-files.sh.tmpl` — `~/.zsh/.zshenv` / `.zshrc` / `zsh-autosuggestions/**/*.zsh` / wk init / zoxide init を `zcompile` して `.zwc` 化
- `run_onchange_after_08a-generate-wk-init.sh.tmpl` / `08b-generate-zoxide-init.sh.tmpl` / `13-generate-ls-colors.sh.tmpl` / `07-rebuild-bat-cache.sh.tmpl` — 各種ツールの init キャッシュ生成

compdump 削除は本物の起動コストではなく一時状態のため、bench 直前に `zsh -ic exit` を 1 回挟んで compdump を再生成しておく。これで前後比較が安定する (apply 直後だけ重い、というアーティファクトを潰す)。`.zwc` や各種 init キャッシュは apply 時にもう生成済みなので追加 warmup は不要。

warmup と bench の間に `chezmoi apply` などを **挟まない**。挟むと compdump が再削除されて「最適化したはずなのに `first_command_lag_ms` が悪化した」のような誤った観察が出る。

## なぜ `MISE_HOOK_ENV_CACHE_TTL=600s` が要るか

`mise activate zsh` が登録する per-prompt hook (`_mise_hook_precmd`) は、通常実シェルでは `should_exit_early_fast` (mise の `src/hook_env.rs`) の filesystem チェックを通って ~5ms で early-return する。だが zsh-bench が起動する bench shell の環境下ではなぜかこの fast-path が失敗し、毎 precmd で `Config::load` (~130ms) が走る。これに引きずられて `command_lag_ms` が実シェルの体感 (~5ms) と大きく乖離した値 (~140ms) で計測されてしまうため、bench の数字を実体感の指標として使えなくなる。

`MISE_HOOK_ENV_CACHE_TTL=600s` を立てると、`~/.local/state/mise/last_full_check` の最終 full check タイムスタンプから TTL ウィンドウ内なら `should_exit_early_fast` の filesystem チェック群を一括 skip して true を返すため、fast-path が成立する。これで bench shell が実シェルと同じ振る舞いになり、`command_lag_ms` がユーザーの体感と一致する。

TTL 中は config / DATA dir / watch_files の更新が検出されないが、bench 用途では完全に無害 (短時間で 1 回の bench を回すだけ)。
