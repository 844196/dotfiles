# 個人閾値が作者値とズレている理由

zsh-bench README で示されている作者の閾値と、本リポジトリで採用している個人閾値は次のようにズレている:

| メトリクス | 個人閾値 | 作者値 | 倍率 |
|---|---|---|---|
| `command_lag_ms` | 8ms | 10ms | 1.1 倍敏感 |
| `first_prompt_lag_ms` | 234ms | 50ms | 4.7 倍鈍感 |
| `first_command_lag_ms` | 360ms | 150ms | 2.4 倍鈍感 |
| `input_lag_ms` | 70ms | 20ms | 3.5 倍鈍感 |

ズレの構造は「個人感度の差」と「lag が他要因に吸収されるかどうか」の 2 軸。`first_prompt_lag_ms` / `first_command_lag_ms` / `input_lag_ms` の 3 つは起動 overhead や打鍵時間に lag が吸収されるため作者値より鈍感に出る (大きな閾値) 一方、`command_lag_ms` は実用シナリオで素直に追従するため敏感に出る (小さな閾値)。

## 個人感度が作者より高い → 敏感 (作者値より小さく出る)

- **`command_lag_ms` 8ms (作者値 10ms の 1.1 倍敏感)** — playground で短いコマンド (`pwd`、`ls`、`:` など) を打って Enter を繰り返す実用シナリオで判定。出力を眺めたり次のコマンドを打ち始めたりする自然な操作の流れの中で、Enter → 次プロンプト表示までの遅延を識別する。空 Enter 連打 + 空白フレーム凝視のような最高感度シナリオで測ると 5ms 程度まで詰められるが、実用とは乖離するためこちらの値を採用。

## 起動 overhead / 打鍵時間吸収 → 鈍感 (作者値より大きく出る)

- **`first_prompt_lag_ms` 234ms (作者値 50ms の 4.7 倍鈍感)** — `human-bench` を `tmux split-window` 経由で起動 (zsh-bench README:190-193 の著者意図シナリオ = 新ペイン起動で zsh 起動レイテンシを測る、著者は「split an existing tab」と表現) して、`Y` 押下から新ペインのプロンプト出現までの時差で判定。新ペイン起動 + zsh 起動の overhead が baseline に乗るため、追加 lag が視認しにくい。`exec zsh` シナリオで測れば 5ms 程度まで詰められるが、ユーザーが日常的に zsh を起動するシナリオは新ペイン起動 (terminal の新タブ、tmux pane 分割など) なので、こちらの値を採用。
- **`first_command_lag_ms` 360ms (作者値 150ms の 2.4 倍鈍感)** — `human-bench` の lag は絶対時刻方式 (`_ZB_START_TIME_SEC + lag` まで sleep) で、`Y` 押下からコマンド入力 Enter までの打鍵時間に lag が吸収される。これは現実の体感とも整合している — ターミナルを開いて即座に何かを打たない限り、起動 lag は手の動きに紛れて見えない。
- **`input_lag_ms` 70ms (作者値 20ms の 3.5 倍鈍感)** — 1 文字の追従遅延が打鍵間隔に吸収される (タイピング速度に依存)。
