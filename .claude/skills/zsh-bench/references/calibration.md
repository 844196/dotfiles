# 個人閾値の再較正

ハードウェア・ターミナル・OS が変わったときなど、4 メトリクスの個人閾値を取り直したい場合は `human-bench` で盲検テストする。tmux セッション内にいる前提。

各オプションは `0` と「テストしたい候補値」をペアで複数指定すると、各試行で被験者にバレないようランダム選択され → playground を抜けると `Chosen value: --xxx-lag-ms <N>` で答え合わせ (例: `-p 0 -p 100`)。`-f` first-prompt-lag, `-c` first-command-lag, `-p` command-lag, `-i` input-lag。

二分探索で「ほぼ全問正解 (≥80%)」と「正答率 50% 付近 (まぐれ当たり)」の境界を詰める。1 候補値あたり 10 試行、二分探索 5〜7 段階で十分絞り込める。

`zsh-bench` 本体と違い `human-bench` には `MISE_HOOK_ENV_CACHE_TTL` も `ZSH_BENCH` も不要。playground は素の `zsh` が立ち上がるだけで `script -fqec` の PTY ラップが入らないため mise の slow path に落ちず、メトリクスごとの判定方法も wk トリガーキー (スペース・カンマ) を含まない。

## エージェント駆動: tmux 別ペインで盲検試行を回す

ユーザーが tmux 内にいてエージェント (Claude Code など) と対話している場合、エージェントが候補値を決めて別ペインで human-bench を起動 → ユーザーが新ペインで盲検試行 → 結果を元のペインで報告 → エージェントが集計して次の候補値を決定、というループで較正できる。手作業でブラケット管理や正答率計算をやらずに済む。

ユーザーは新ペインで 10〜15 試行 → 各試行の判定と答えを `判定 / 答え` の 1 試行 1 行形式 (e.g. `clean / 0`、`laggy / 30`) で元のペインに貼り戻す。エージェントは正答数を集計し、≥80% なら検出可能・〜50% なら不可能として二分探索を進める。

ループ運用のコツ:

- **最初に両端を確定する**: 「絶対検出できる」高い値と「絶対検出できない」低い値でブラケットを取ってから二分探索に入る。中央から始めるとたまたま 50% で止まったときに上下どちら側に進むべきか分からない
- **1 候補値あたり最低 10 試行**: 6 試行程度ではウォームアップ効果 + ノイズで結果が反転しうる (実例: 30ms で初回 6 試行 50% → 再テスト 14 試行 100% という反転を経験)
- **境界付近では試行数を増やす**: 正答率 80% 付近のメトリクスはサンプル数を増やさないと判定が揺れる。12〜15 試行で再テスト
- **反転したら再テスト**: 思いがけずチャンスレベルが出たら、その値で再度試行を回し、ノイズか本物かを切り分けてから次に進む

## メトリクスごとのコマンドと判定方法

判定方法は結果に大きく影響するため、毎試行同じ条件で行う。`<N>` は候補値 (ms)。

### `command_lag_ms` (`-p`)

```bash
tmux split-window -v -l 60% "$HOME/.zsh/zsh-bench/human-bench -p 0 -p <N>"
```

playground で短いコマンド (`pwd`、`ls`、`:` など) を打って Enter を繰り返す実用シナリオ。Enter → 次プロンプト表示までの遅延を、出力を眺めたり次のコマンドを打ち始めたりする自然な操作の流れの中で識別する。空 Enter 連打 + 空白フレーム凝視は最高感度シナリオで実用とは乖離するため使わない。

### `first_command_lag_ms` (`-c`)

```bash
tmux split-window -v -l 60% "$HOME/.zsh/zsh-bench/human-bench -c 0 -c <N>"
```

`Y` Enter 直後に **最短コマンド `:` を即打鍵 + Enter**。コマンドは 1 文字に固定 — `human-bench` の lag は絶対時刻方式 (`_ZB_START_TIME_SEC + lag` まで sleep) で実装されており、打鍵時間が伸びると lag が吸収されて消える。これは「現実でも手の遅さで起動 lag が見えなくなる」現象とも整合しているため、結果を個人の体感閾値として正当に採用できる。

### `input_lag_ms` (`-i`)

```bash
tmux split-window -v -l 60% "$HOME/.zsh/zsh-bench/human-bench -i 0 -i <N>"
```

playground で長めの行を入力し、各文字が打鍵に追従して画面に出る速度を見る。タイピング速度に依存 (打鍵間隔より短い lag は吸収されて見えない)。

### `first_prompt_lag_ms` (`-f`)

```bash
tmux split-window -v -l 60% "$HOME/.zsh/zsh-bench/human-bench -f 0 -f <N> -s 'tmux split-window -v -l 60% -e ZDOTDIR=\$ZDOTDIR -e _ZB_ORIG_ZDOTDIR=\$_ZB_ORIG_ZDOTDIR -e _ZB_FIRST_PROMPT_LAG_MS=\$_ZB_FIRST_PROMPT_LAG_MS -e _ZB_START_TIME_SEC=\$_ZB_START_TIME_SEC'"
```

> 注意: コマンドを書き換える際の落とし穴 2 つ。**(1) `-s` の末尾に `zsh` を入れない** (default-shell = zsh が 1 段で起動するように shell-command を省略)。**(2) `\$ZDOTDIR` 等のバックスラッシュエスケープを外さない** (outer 展開を抑止して human-bench の eval 時に展開させる)。それぞれの理由は下記。

zsh-bench README:190-193 の著者意図シナリオ = 新ペイン起動で zsh 起動レイテンシを測る。outer split-window で human-bench を起動 → `Y` 押下 → human-bench が `-s` の中身を eval して inner split-window が走り、その新ペインのプロンプト出現までの時差で判定。

(1) `-s` 末尾に `zsh` を入れると、tmux が default-shell で `zsh -c "zsh"` の 2 段 shell を起動して内側 zsh が `internal/zdotdir/.zshenv` を読まず `-zb-precmd` が登録されないため lag が効かない (`typeset +x -gF` で export 解除されて子に伝わらない)。shell-command を省略すれば default-shell (= zsh) が 1 段で起動して precmd 登録される。

(2) `\$ZDOTDIR` 等のエスケープを外すと、outer の `tmux split-window "..."` の二重引用内で先に展開されてしまう。outer 展開時点では `_ZB_*` がまだ未設定なので、ここで展開されると空文字になって lag が効かない。エスケープしておけば human-bench の eval 時に展開される。
