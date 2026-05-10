---
name: zsh-bench
description: zsh の対話シェルとしての user-visible なレイテンシ (起動時間、コマンド実行時の重さ、キー入力の追従性) を zsh-bench で計測し、結果を人間の知覚閾値と照らして評価する。「`.zshrc` を最適化したい」「プラグインを足した/削った前後で性能を比較したい」「zsh-bench を走らせたい」といった zsh のパフォーマンス系のリクエストでは必ずこのスキルを使う。
---

# zsh-bench スキル

このスキルは **844196/dotfiles 専用**。zsh-bench は ghq で `romkatv/zsh-bench` を取得済みである前提で、計測コマンドの環境変数も本リポジトリの `.zshrc` 構造 (mise activate / wk トリガー / 自動 tmux exec) を前提とする。

未取得なら計測前に取得しておく (`ghq list --full-path --exact romkatv/zsh-bench` は未取得時に空文字列を返すので、その場合のみ `ghq get` を呼ぶ):

```bash
ghq list --full-path --exact romkatv/zsh-bench | grep -q . || ghq get https://github.com/romkatv/zsh-bench
```

## 大前提: 前後比較で語る

このスキルの主目的は「変更前 → 変更後の比較」であって、絶対値の良し悪しを言うことではない。zsh-bench の値はマシン・OS・電源プロファイル・裏処理の負荷に左右されるため、絶対値で「速い/遅い」と言っても意味が薄い。**1 回しか計測していないなら改善の根拠にしない**。

例外は「閾値を明らかに大幅超過しているメトリクスがある」ケース (e.g. `command_lag_ms` が 200ms など)。この場合は絶対値だけでも「明らかに遅い」と判断してよい。さらにこの場合、数字を渡して終わりにせず、[観察値の解釈に踏み込むとき](#観察値の解釈に踏み込むとき) に従って原因仮説まで踏み込む。

## TL;DR

1. **変更前計測 → 変更 → `chezmoi apply` → 変更後計測**。前後とも下の warmup 込み 1 ライナーで測る:

   ```bash
   zsh -ic exit && MISE_HOOK_ENV_CACHE_TTL=600s ZSH_BENCH=1 NO_TMUX=1 "$(ghq list --full-path --exact romkatv/zsh-bench)/zsh-bench" --iters 32
   ```

2. 報告は **絶対値 + 正規化値 (実測 ÷ 個人閾値) + 体感帯 (🟢 / 🟡 / 🟠 / 🔴)** の 3 点セット。機能フラグ (`has_*`) の差分も併記する。
3. レイテンシ閾値超過 (🟠 / 🔴) なら zsh 設定を読んで原因仮説まで踏み込む。閾値内 (🟢 / 🟡) なら数字を報告して終わる。機能フラグ (`has_*`) の値は数字提示にとどめ、解釈・原因推測を加えない。

> なお `exit_time_ms` は対話シェルの体感と乖離するため性能指標として無視する。

## ワークフロー

前後比較を想定した 4 ステップ。ヘルスチェック (現状診断) なら Step 1 と Step 4 だけでよい (例外条件の詳細は [大前提](#大前提-前後比較で語る))。

### 1. 「変更前」を計測

何かを変える前にまず baseline を取る。TL;DR の正典 1 ライナーで実行し、出力をそのまま (or メモに) 残す。コマンドの中身は [計測コマンドの詳細](#計測コマンドの詳細) を参照。

### 2. 変更を適用

`.zshrc` 編集、プラグイン追加/削除、`compinit` 設定変更などを行う。chezmoi 管理下の変更なら `chezmoi apply` まで完了させてから次へ進む (ソースだけ書いてもターゲットの `~/.zshrc` には反映されない)。

### 3. 「変更後」を計測

Step 1 と同じ 1 ライナーで再計測。`zsh -ic exit` (compdump warmup) と bench は同じコマンドラインで繋ぐこと — 間に `chezmoi apply` などが挟まると compdump が再削除されて `first_*_lag_ms` が悲観的に出る (詳細は [warmup の構造][warmup])。

### 4. 差分を比較して報告

レイテンシ系メトリクス (`first_prompt_lag_ms` / `first_command_lag_ms` / `command_lag_ms` / `input_lag_ms`) について、絶対値・正規化値・体感帯の 3 点セット + 機能フラグ差分で報告する。フォーマットの詳細と例は [評価帯と報告フォーマット](#評価帯と報告フォーマット) を参照。

変更後のレイテンシが閾値超過 (🟠 / 🔴) したまま残っているなら、[観察値の解釈に踏み込むとき](#観察値の解釈に踏み込むとき) に従って原因仮説まで踏み込む。前後の差が誤差レベル (`command_lag_ms` で 1〜2ms 程度、他で数 ms 程度) と疑わしい場合は [iter 数の選び方](#iter-数の選び方) に従って `--iters` を上げて再測する。

## 計測コマンドの詳細

### 環境変数の意味

3 つとも常に付ける。どれか欠けても計測値の意味が壊れる。

- `MISE_HOOK_ENV_CACHE_TTL=600s` — bench shell でも mise hook の fast-path を成立させ、`command_lag_ms` を実シェルの体感に揃える。これがないと per-precmd で `Config::load` が走って `~140ms` で計測されてしまう (詳細は [warmup の構造][warmup])
- `ZSH_BENCH=1` — `~/.zshrc` の wk トリガー (`bindwidget ' '` / `bindwidget ','`) を無効化。これがないと計測中のスペース/カンマ入力でウィジェットが起動して完走しない ([zshrc][zshrc] の `if [[ -z "$ZSH_BENCH" ]]; then` ブロック)
- `NO_TMUX=1` — `~/.zshrc` 冒頭の VSCode workspace 用 `exec tmux new-session ...` を無効化。これがないと bench 用の zsh が tmux に置き換わる ([zshrc][zshrc] 冒頭の `${NO_TMUX+X}` ブロック)

### `zsh -ic exit` の役割

**compdump warmup**。`chezmoi apply` 直後は `~/.cache/zsh/compdump*` が削除されており、初回 zsh 起動時に `compinit` が compdump を再生成する。これが計測に紛れ込むと `first_prompt_lag_ms` / `first_command_lag_ms` が悲観的に出るので、bench 直前に 1 回起動して再生成しておく (詳細は [warmup の構造][warmup])。

### iter 数の選び方

zsh-bench は内部で複数回計測して中央値を出すが、それでも数 ms 程度のばらつきはある。正典で `--iters 32` を必須にしているのは、zsh-bench 標準の 16 iter だと特に `command_lag_ms` (個人閾値 8ms) のように閾値帯が狭いメトリクスで、ノイズが帯境界 (🟢/🟡/🟠) を跨いで誤判定しやすいため (実例: 16 iter で `command_lag_ms=7.4ms` (🟡 上端の 92%) が、32 iter で `0.5ms` (🟢 の 6%) に変わった — 16 iter ではノイズ次第で 🟠 へも飛びうる位置)。

それでも前後の差が `command_lag_ms` で 1〜2ms 程度、他のメトリクスで数 ms 程度しかなく誤差が疑わしい場合は、`--iters 64` 以上に上げて再測する:

```bash
zsh -ic exit && MISE_HOOK_ENV_CACHE_TTL=600s ZSH_BENCH=1 NO_TMUX=1 "$(ghq list --full-path --exact romkatv/zsh-bench)/zsh-bench" --iters 64
```

再測でも差が安定して残れば本物、消えればノイズ。iter を増やすと計測時間も比例して伸びる (毎 iter で各メトリクス用の zsh 起動が走るため。なかでも `exit_time_ms` 計測の `zsh -lic "exit"` がコスト大)。

WSL2・ノート PC の電源状態・裏で動いている重い処理 (chezmoi apply 直後、mise install 中など) は値を大きく揺らす。負荷が落ち着いてから測る。

## 結果の読み方

### 出力フォーマット

```
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=0
first_prompt_lag_ms=5.106
first_command_lag_ms=322.089
command_lag_ms=135.403
input_lag_ms=0.229
exit_time_ms=139.672
```

前半 (`creates_tty` / `has_*`) は機能の有無 (0/1)、後半 (`*_ms`) がレイテンシ (ミリ秒)。

### 機能フラグ

| キー | 意味 |
|---|---|
| `creates_tty` | tmux/screen を起動して新しい TTY を作っているか。本リポジトリは `NO_TMUX=1` を必須にしているため通常は 0 で固定 |
| `has_compsys` | `compinit` で「new」補完システム (`compdef` ベース) を初期化しているか。`compinit` を呼んでいれば 1、古い `compctl` だけだと 0 |
| `has_syntax_highlighting` | zsh-syntax-highlighting で構文ハイライトが効いているか |
| `has_autosuggestions` | zsh-autosuggestions による補完候補表示が効いているか |
| `has_git_prompt` | プロンプトに git ブランチが出ているか |

`has_git_prompt` の意味は「プロンプトの出力テキストにランダムブランチ名が現れるか」であって「リポジトリの有無」ではない (zsh-bench は計測対象 zsh をデフォルトで git リポ済みの tmpdir で起動する)。各フラグの正確な意味やデフォルト[計測環境の内部仕様][measurement-environment]を参照。**ユーザーから機能フラグについて質問・指摘があった場合**、または**前後比較で値が変化した場合**に限り、ここと本リポ設定を読んで答える。エージェント自身が「気になった」を起点に踏み込んではいけない (設定を読まないまま連想で書くと、実際には使っていないツールを「現在の設定」と混同する事故が起きる)。

### レイテンシメトリクス

| キー | 何の時間 | 高いとどうなる |
|---|---|---|
| `first_prompt_lag_ms` | shell 起動 → 最初のプロンプト表示まで | ターミナルを開くと一瞬空画面を眺める時間ができる |
| `first_command_lag_ms` | shell 起動 → 最初の対話コマンドの実行開始まで | ターミナル開いた直後に素早く `ls` を打つと待たされる |
| `command_lag_ms` | 空 Enter → 次のプロンプト表示まで | 全コマンドが少し重く感じる (Enter 押下と次プロンプト表示の間か、コマンド終了と次プロンプトの間で遅延) |
| `input_lag_ms` | 1 文字キー入力 → その文字が画面に出るまで (長い行が引かれた状態で計測) | キー入力がもったり感じる (高レイテンシ SSH 越しのような感覚) |
| `exit_time_ms` | `zsh -lic "exit"` の所要時間 | **無視**。zsh-bench README が「meaningless」と断言しており、対話シェルの体感とは乖離する。プラグインマネージャ性能比較で広く使われていた指標だが、日常的に `zsh -lic "exit"` を打たない限り意味がない |

> 補足: 表中の説明は zsh-bench の計測実装。`command_lag_ms` の個人閾値は別シナリオ (短いコマンド `pwd` / `ls` / `:` などを打って Enter を繰り返す実用シナリオ) で較正している (詳細は [閾値の根拠][threshold-rationale])。

### 個人閾値

「これより下なら 0ms と区別できない」閾値。4 メトリクスとも `human-bench` での盲検テストで較正した **個人閾値**。

| メトリクス | 閾値 | 出典 |
|---|---|---|
| `first_prompt_lag_ms` | 234ms | 個人閾値 (新ペイン起動シナリオ) |
| `first_command_lag_ms` | 360ms | 個人閾値 |
| `command_lag_ms` | 8ms | 個人閾値 |
| `input_lag_ms` | 70ms | 個人閾値 |

作者値とのズレ (`command_lag_ms` のみ作者値より敏感、他 3 つは作者値より鈍感) のメトリクス別根拠は [閾値の根拠][threshold-rationale]を参照。ハードウェア・ターミナル・OS が変わって閾値を取り直したい場合は [較正手順][calibration]を参照。

### 評価帯と報告フォーマット

正規化値 = 実測 ÷ 個人閾値 で評価する:

| 帯 | 範囲 | 体感 |
|---|---|---|
| 🟢 | <50% | 余裕で知覚不能。ヘッドルームたっぷり |
| 🟡 | 50% – 100% | 閾値内。知覚不能だが余裕は少ない |
| 🟠 | 100% – 200% | 知覚可能。気になる |
| 🔴 | >200% | 明らかに遅い |

報告するときは絶対値・正規化値・体感帯の 3 点セットで翻訳し、機能フラグ (`has_*`) の差分も併記する。機能を増やせばレイテンシが増えるのは当たり前なので、フラグの差を踏まえずレイテンシだけ比較すると誤判断する (e.g.「`has_syntax_highlighting` が 0 → 1 に変わったので `command_lag_ms` 増加は妥当」)。

例:

```
first_prompt_lag_ms:    105ms → 65ms  (45% → 28%, 🟢 → 🟢)
first_command_lag_ms:   180ms → 120ms (50% → 33%, 🟡 → 🟢)
command_lag_ms:         18ms  → 4ms   (225% → 50%, 🔴 → 🟡)
input_lag_ms:           12ms  → 11ms  (17% → 16%, 🟢 → 🟢)
has_syntax_highlighting: 0 → 1 (機能追加 — 上記 command_lag_ms の差はこれを踏まえて評価)
```

報告に書くのはこの 3 点セット + 機能フラグ (`has_*`) の値 (前後比較時は差分) まで。**機能フラグについては数字を提示するだけにとどめ、値の解釈・原因推測・具体ツール名やプラグイン名に踏み込まない** — 「`has_git_prompt=0` だから X を疑え」のような所感は、設定を読まないまま LLM の連想で書くと実際には使っていないツールを「現在の設定」と混同する事故が起きる。

エージェントが機能フラグについて踏み込むのは、(a) ユーザーから質問・指摘があった場合、または (b) 前後比較で値が変化した場合に限る。どちらの場合も、[計測環境の内部仕様][measurement-environment]でフラグの意味を確認した上で、本リポの設定 ([zshrc][zshrc] 等) を読んでから答える。

レイテンシも閾値内なら同様で、設定を読みに行かず数字を報告して終わる。閾値超過したものがあるときだけ [観察値の解釈に踏み込むとき](#観察値の解釈に踏み込むとき) のパスを通る。

## 観察値の解釈に踏み込むとき

レイテンシメトリクスが閾値超過 (🟠 / 🔴) しているときは、このパスを通る (機能フラグ関連の起動条件は前節「評価帯と報告フォーマット」を参照)。

測定そのものは目的ではない。**ユーザーが次に何をすればいいか判断できる材料を揃えるのが目的**。「数字を翻訳して終わり」「一般論で『次の一手』を並べて終わり」では役に立たない — 一般論はエージェントが介在しなくてもユーザー自身が書ける。

したがって、**閾値超過しているレイテンシがあれば、現在の zsh 設定を読んで原因の当たりを付け、ファイル名・行番号付きで「ここがこういう理由で怪しい」までを報告に含める**。

逆に、**全レイテンシが閾値内 (🟢 / 🟡)** なら原因仮説は不要。数字 (機能フラグ含む) を報告して終わる。健康な設定を根掘り葉掘り読みに行くのは時間の無駄。

### compdump warmup の抜けを疑う (起動系メトリクス)

`first_prompt_lag_ms` / `first_command_lag_ms` が悲観的に出ている、または起動 zprof で `compinit` / `compdump` が支配的なら、**compdump warmup の抜け** の可能性が高い ([warmup の構造][warmup])。[clear-compdump][clear-compdump] で apply ごとに compdump が消えるため、apply 直後の初回起動 1 回分だけ重い、というのが定型パターン。`zsh -ic exit` を bench 直前に挟んでから再測し、同じ重さが残るなら本物の起動コストとして扱う。

### どのメトリクスは zsh のどこを読めば原因が分かるか

| 閾値超過したメトリクス | 起源候補として読む場所 |
|---|---|
| `first_prompt_lag_ms` | `.zshenv` / `.zprofile` / `.zshrc` の起動時に同期実行される箇所 (プラグインマネージャ初期化、`compinit`、`source` チェーン、外部コマンド呼び出し) |
| `first_command_lag_ms` | 上記に加え、初回 precmd・zle widget 登録・PROMPT 構築の初期化 |
| `command_lag_ms` | `precmd_functions` / `preexec_functions` に登録されたフック、PROMPT 変数の動的構成、毎回呼ばれる git status |
| `input_lag_ms` | zle widget、syntax-highlighting / autosuggestions の前処理、`bindkey` にぶら下がる重いウィジェット |

### どのファイルを読むか

chezmoi ソース側 ([zshrc][zshrc]、[zshenv](../../../files/exact_dot_zsh/dot_zshenv.tmpl)、[zsh の自作関数](../../../files/exact_dot_zsh/exact_functions/) など) を読む。実体は `~/.zshrc` だが、編集対象として自然なのはソース側。`source` で読み込まれている関連ファイルも追う。

**[chezmoiscripts][chezmoiscripts] も合わせて見る**。このリポジトリでは「起動時にやらず apply 時に先回りキャッシュ化する」ことで起動コストを削る方針が採られている (zsh ファイルの `zcompile`、zoxide / wk / ls-colors / bat キャッシュ生成など)。`first_prompt_lag_ms` / `first_command_lag_ms` の改善案を出すときは「`.zshrc` で同期実行している処理を [chezmoiscripts][chezmoiscripts] で apply 時に先回り cache 化する」が選択肢に入る。

### 仮説であることを明示する

設定を読んだだけでは原因は確定しない。「`precmd_functions` に登録されている `_foo_hook` が同期で外部コマンドを呼んでおり、`command_lag_ms` の主因と推測される」とは言えるが、「これが原因」と断定はしない。

確証には次のいずれかが要る:
- `zprof` で関数別の累計時間を取る (`zmodload zsh/zprof` を `.zshrc` 冒頭に入れて起動 → `zprof` で結果表示。ただし precmd/preexec の重さは別途測る必要がある)
- 怪しいフック・プラグインを一時的に外して再計測し、実測差を確認する
- `zsh -xv` で実行トレースを取る

報告の最後には、**犯人候補に応じた具体的な検証手順** (「`exact_dot_zsh/dot_zshrc:N` の `_foo_hook` を一時的にコメントアウトして再計測する」など) を 1 つ添える。一般論ではなく、いま挙げた仮説を確かめるための手順として。

## 報告チェックリスト

- [ ] 絶対値 + 正規化値 + 体感帯の 3 点セットで翻訳した
- [ ] 機能フラグ (`has_*`) を確認した (前後比較時は差分も併記)
- [ ] 機能フラグの値について解釈・原因推測・具体ツール名を書いていない (数字提示にとどめている)
- [ ] `exit_time_ms` で性能を語っていない
- [ ] (前後比較時) 32 iter で前後差が誤差レベルなら `--iters 64` 以上で再測した

## 関連ドキュメント

- [warmup の構造][warmup] — 正典コマンドの warmup 構造。`zsh -ic exit` で compdump を再生成しておく理由 (apply 直後だけ重いアーティファクトを潰す)、`MISE_HOOK_ENV_CACHE_TTL=600s` で mise hook-env の fast-path を強制する理由 (bench shell では fast-path がなぜか効かないため、実シェル相当の `command_lag_ms` を測るために必要)
- [計測環境の内部仕様][measurement-environment] — zsh-bench の計測環境の内部仕様。HOME は本物だが CWD が `/tmp/zsh-bench-XXXXXXXXXX/<random-cwd>` (デフォルト `--git yes` で 10000 ファイルの git リポ済み)、`has_git_prompt` の正確な意味、CWD 依存ロジック (`mise.toml` / `.envrc` のような CWD 依存設定ファイル探索) のズレ。異常値解釈時に読む
- [閾値の根拠][threshold-rationale] — 個人閾値が zsh-bench 作者値と異なる理由のメトリクス別解説。`command_lag_ms` のみ敏感、他 3 つは起動 overhead や打鍵時間に lag が吸収されて鈍感、という構造
- [較正手順][calibration] — 個人閾値の再較正手順。`human-bench` での盲検試行、tmux 別ペイン経由のエージェント駆動ループ、メトリクスごとの判定方法

[warmup]: references/warmup.md
[measurement-environment]: references/measurement-environment.md
[threshold-rationale]: references/threshold-rationale.md
[calibration]: references/calibration.md
[zshrc]: ../../../files/exact_dot_zsh/dot_zshrc
[chezmoiscripts]: ../../rules/chezmoiscripts.md
[clear-compdump]: ../../../files/.chezmoiscripts/run_after_08-clear-compdump.sh

## このスキルが扱わないもの

- `zsh-bench --isolation docker` での複数 config 比較 — 別 zsh 設定との比較は対象外、自分の `.zshrc` を測る用途に集中
- zsh 以外のシェル (bash / fish 等) のベンチマーク
