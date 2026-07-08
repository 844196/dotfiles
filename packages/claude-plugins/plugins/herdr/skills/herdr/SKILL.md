---
name: herdr
description: herdr（ターミナルマルチプレクサ、https://herdr.dev/）の中で動いているときに、workspace・tab・pane・agent をソケット API 経由で操作する。他 pane の出力を読む、コマンドを実行する、出力やエージェント状態の変化を待つ、新しいエージェントを起動する、pane のレイアウトを操作する、git worktree を作る、といった操作をするときに使う。HERDR_ENV=1 で動いているときのみ有効。
---

# herdr — agent skill

使う前に `HERDR_ENV=1` かどうかを確認する。設定されていなければ、herdr が管理する pane の中で動いていないということなので、そう伝えて止める。herdr の外からフォーカス中の pane を操作・覗き見しようとしない。

herdr は workspace・tab・pane を提供するターミナルネイティブなエージェントマルチプレクサ。各 pane はそれぞれ独立したシェル・エージェント・サーバー・ログストリームを持つ実体のあるターミナルで、`herdr` バイナリ経由でこれら全てを CLI から操作できる。

やれること:

- 他の pane・エージェントが何をしているか見る
- workspace 内に tab を作ってサブコンテキストを分ける
- pane を分割してコマンドを実行する
- サーバーを起動する、ログを見る、隣の pane でテストを走らせる
- 特定の出力が出るまで待つ
- 他のエージェントが完了するまで待つ
- 新しいエージェントインスタンスを起動する
- pane を別の tab・workspace に移動する、zoom する
- git worktree を作って新しい workspace として開く

`herdr` はすでに PATH に入っている。生のソケット API プロトコルやフルリファレンスが必要なら [socket API docs](https://herdr.dev/docs/socket-api/) を読む。

## 概念

**workspace** はプロジェクトのコンテキスト。1つ以上の tab を持つ。手動でリネームしない限り、最初の tab のルート pane に追従してラベルが決まる (大抵はリポジトリ名、そうでなければ pane の cwd のフォルダ名)。

**tab** は workspace 内のサブコンテキスト。1つ以上の pane を持つ。

**pane** は tab 内のターミナル分割。それぞれ独立したプロセス (シェル・エージェント・サーバー、何でも) を実行する。

**agent status** は herdr が自動検出する。公開フィールドは1つ:

- `agent_status` — `idle` / `working` / `blocked` / `done` / `unknown`

`done` は「エージェントは終わったが、まだこの pane を見ていない」という意味。

**id 形式**: workspace id は `w1Z` のような短い安定ハンドル、tab id は `w1Z:t1`、pane id は `w1Z:p1` の形式。close した直後に同じ階層で新しく作っても id が使い回されず次の値に進むことを、pane・tab・workspace の3階層すべてで実機再現して確認済み (例: pane を close → 次の split は次の連番、workspace を close → 次の create は別の id)。新しく作った pane/tab/workspace の id は `workspace create` / `tab create` / `pane split` などのレスポンスから毎回読み取ること（後述）。

**target (agent サブコマンド用)**: `herdr agent` 系コマンドが受け付ける識別子。terminal id (`term_...`)、`herdr agent start` で付けた一意な名前、検出/報告されたエージェントラベル、レガシーな pane id のいずれでも指定できる。

## agent サブコマンド と pane サブコマンド の関係

`herdr pane <sub>` が低レベルの基盤で、`herdr agent <sub>` はその上に乗った「エージェント指向」のエルゴノミックなレイヤー。`pane` 系は pane id を要求するのに対し、`agent` 系は上記の target (名前・ラベル・terminal id なども) で引ける。

| したいこと | pane 系 | agent 系 |
|---|---|---|
| 一覧 | `herdr pane list` | `herdr agent list` |
| 詳細取得 | `herdr pane get <pane_id>` | `herdr agent get <target>` |
| 出力を読む | `herdr pane read <pane_id> ...` | `herdr agent read <target> ...` |
| テキスト送信 (Enter 無し) | `herdr pane send-text <pane_id> <text>` | `herdr agent send <target> <text>` |
| 状態を待つ | `herdr wait agent-status <pane_id> --status ...` | `herdr agent wait <target> --status ...` |
| フォーカス | (`pane focus` は方向指定のみ) | `herdr agent focus <target>` |
| アタッチ | (無し) | `herdr agent attach <target> [--takeover]` |
| 新規起動 | `herdr pane split` + `pane run` | `herdr agent start <name> ...` |
| 検出理由の説明 | (無し) | `herdr agent explain <target> [--json]` |

新しく他のエージェントを起動・監視・操作する用途なら `agent` 系を第一候補にする。既存 pane のレイアウト操作 (分割・移動・zoom・resize) は `pane` 系にしかない。

## discover yourself

自分がどの pane かは、herdr が自分の pane プロセスに直接渡している環境変数で分かる。コマンドを呼ばずに済むので、これが一番手軽:

```bash
echo "$HERDR_PANE_ID" "$HERDR_TAB_ID" "$HERDR_WORKSPACE_ID"
```

`HERDR_PANE_ID` は起動後 pane が生きている限り変わらないので、この用途では信頼できる。一方 `HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` は pane プロセス起動時点のスナップショットで、以降 herdr 側の状態が変わっても自動更新されない。実機で確認済み: `pane move` で別 tab に移した pane で `printenv HERDR_TAB_ID` を実行しても、移動先ではなく移動前の tab id が返り続けた (`HERDR_PANE_ID` は移動後も正しい値のまま)。この2つの環境変数を「自分が今いる tab/workspace」の判定に使う場合、自分の pane が `pane move` で動かされた可能性があるなら鵜呑みにしない。

確実な現在値が要る場合 (直前に自分が `pane move` された可能性がある、等) は `pane current` で問い合わせる:

```bash
herdr pane current
```

これは呼び出し元 (自分が動いている pane) を毎回ライブに解決して返す。`pane list` の `focused` フィールドと混同しないこと — `focused` は UI 上どこにカーソルがあるかを示すだけで、それが自分の pane と一致するとは限らない (ユーザーが別の pane をクリックしていれば `focused` はそちらに移る。実機で確認済み: focus を他 workspace に移しても、自分の pane から見た `pane current` の `pane_id` は変わらず `focused` フィールドだけが `false` になった)。`pane list` は「いま存在する pane 一覧」を見るのに使い、自分自身の特定には使わない:

```bash
herdr pane list
```

一覧に出てくる自分以外の pane が隣人。

エージェントだけを見たいなら:

```bash
herdr agent list
```

workspace 一覧:

```bash
herdr workspace list
```

## tab management

workspace 内の tab 一覧:

```bash
herdr tab list --workspace w1Z
```

tab を作る (`--label` を付けなければ番号付けされたデフォルト名のまま):

```bash
herdr tab create --workspace w1Z --label "logs"
```

リネーム・フォーカス・close:

```bash
herdr tab rename w1Z:t2 "logs"
herdr tab focus w1Z:t2
herdr tab close w1Z:t2
```

## 他 pane の出力を読む

```bash
herdr pane read w1Z:p1 --source recent --lines 50
```

- `--source visible` = 現在のビューポート
- `--source recent` = pane にレンダリングされた最近のスクロールバック
- `--source recent-unwrapped` = ソフトラップを結合した最近のターミナルテキスト

`agent read <target> ...` も同じ `--source` / `--lines` / `--format` オプションを取るが、出力そのものは `pane read` と違って JSON になる (詳細は notes を参照)。

## pane の分割・レイアウト操作

右に分割してフォーカスは自分の pane のままにする:

```bash
herdr pane split w1Z:p2 --direction right --no-focus
```

JSON が返り、新しい pane id は `result.pane.pane_id` にネストされている。それを取り出してコマンドを実行する:

```bash
NEW_PANE=$(herdr pane split w1Z:p2 --direction right --no-focus | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
herdr pane run "$NEW_PANE" "npm run dev"
```

レイアウトを触るコマンド群 (すべて `[--pane ID|--current]` を取り、省略時は呼び出し元の pane が対象。UI 上フォーカスされている pane とは限らない):

```bash
herdr pane current                                  # 呼び出し元の pane の情報
herdr pane layout                                   # 現在の tab のレイアウトツリー
herdr pane process-info                             # foreground プロセスの情報
herdr pane neighbor --direction right               # 指定方向の隣接 pane
herdr pane edges                                     # 上下左右に隣接 pane があるか
herdr pane focus --direction left                    # 方向指定でフォーカス移動
herdr pane resize --direction down --amount 0.1      # 方向指定でリサイズ
herdr pane zoom --toggle                             # tab 内で zoom on/off を切り替え
herdr pane swap --direction up                       # 方向指定で pane を入れ替え
```

pane を別の tab・新しい tab・新しい workspace に、プロセスを再起動せずに移動する:

```bash
herdr pane move w1Z:p3 --tab w1Z:t2 --split right
herdr pane move w1Z:p3 --new-tab --workspace w1Z
herdr pane move w1Z:p3 --new-workspace --label "moved"
```

## wait で出力・状態を待つ

サーバー起動やビルド、テストの完了を待つのに使う。`--source recent` はラップ前のテキストにマッチするので、pane 幅やソフトラップの影響を受けない。マッチ対象のテキストをそのまま見たいなら `pane read --source recent-unwrapped` を使う。

```bash
herdr wait output w1Z:p3 --match "ready on port 3000" --timeout 30000
herdr wait output w1Z:p3 --match "server.*ready" --regex --timeout 30000
```

タイムアウトすると exit code は `1`。

他のエージェントが特定の状態になるまで待つ:

```bash
herdr wait agent-status w1Z:p1 --status done --timeout 60000
```

target ベースの `agent wait` も同等のことができるが、**受け付ける `--status` の値が違う** (詳細は罠を参照): `idle|working|blocked|unknown` のみで `done` が無い。UI と同じ `done`/`idle` の区別をしたいなら `wait agent-status` を使う。

```bash
herdr agent wait <target> --status idle --timeout 60000
```

## テキスト・キーを送る

Enter を押さずにテキストだけ送る:

```bash
herdr pane send-text w1Z:p1 "hello from claude"
herdr agent send <target> "hello from claude"
```

Enter や他のキーを送る:

```bash
herdr pane send-keys w1Z:p1 Enter
```

`pane run` はテキスト送信 + 実際の `Enter` キー送信を1リクエストでまとめてやる:

```bash
herdr pane run w1Z:p1 "echo hello"
```

## workspace management

```bash
herdr workspace create --cwd /path/to/project --label "api server"
herdr workspace create --no-focus
herdr workspace focus w1X
herdr workspace rename w1X "api server"
herdr workspace close w1X
```

`--env KEY=VALUE` で環境変数を渡せる (`workspace create` / `tab create` / `pane split` 共通)。

## pane / workspace を close する

```bash
herdr pane close w1Z:p3
```

## 新しいエージェントを起動する: `herdr agent start`

分割 + `pane run` の代わりに、名前付きでエージェントを直接起動できる:

```bash
herdr agent start reviewer --split right --no-focus -- ${user_config.CLAUDE_COMMAND}
herdr agent start reviewer --cwd /path/to/project --workspace w1X --tab w1X:t1 --split down -- codex
```

以降はその名前 (`reviewer`) を target として `agent read` / `agent send` / `agent wait` / `agent focus` から参照できる。

**重要 (実機で検証済み): `-- <argv>` に渡したコマンドが、その pane の実プロセスそのものになる。** シェルにコマンド文字列を打ち込むわけではないので、そのプロセスが終了すると pane ごと自動的に閉じる。`${user_config.CLAUDE_COMMAND}` や `codex` のように自分から終了しない対話的エージェントを起動する分には問題にならないが、一度きりのコマンド (`npm test` など) を実行して後から結果を読みたい場合は、この方式では pane が消えてしまい読めない。その場合は従来通り `pane split` で永続シェルを作ってから `pane run` する (下記レシピ参照)。

## worktree management

git worktree をソケット API 経由で作成・オープンできる:

```bash
herdr worktree list --workspace w1Z
herdr worktree create --workspace w1Z --branch feature/x --label "feature x"
herdr worktree open --workspace w1Z --branch existing-branch
herdr worktree remove --workspace <worktree_workspace_id> --force
```

`create` は worktree を新しい workspace として開く。既存のローカルブランチ名を指定した場合は checkout するだけで、新規作成しようとして失敗することはない。

## session management (named persistent session)

`herdr --session <name>` で使う名前付き永続セッションの一覧・操作:

```bash
herdr session list
herdr session attach <name>
herdr session stop <name>
herdr session delete <name>
```

## notification

```bash
herdr notification show "Build finished" --body "npm run build succeeded" --sound done
```

## agent 検出の理由を調べる: `agent explain`

なぜある pane がその `agent_status` と判定されたのか (マニフェスト・マッチしたルール・根拠) を確認する:

```bash
herdr agent explain <target> --json
```

## 管理系コマンド (このスキルの対象外・参考程度)

以下は herdr 自体のセットアップ・アップデート・プラグイン管理・リモートブリッジ用で、コーディングエージェントが作業中に呼ぶことは基本的に想定されていない。人間のオペレーターが行う操作、もしくは herdr 自体のインフラ:

- `herdr integration install/uninstall/status <agent>` — 各コーディングエージェント向けフック統合のインストール状況
- `herdr channel show|set stable|preview` — アップデートチャンネル
- `herdr update` / `herdr server stop|reload-config|...` — 本体のアップデート・サーバー管理
- `herdr plugin install/link/list/...` — herdr 自身のローカルプラグイン管理
- `herdr completion <shell>` — シェル補完生成
- `herdr terminal attach/session observe|control/title set|clear` — ブリッジプロセス向けの生 ANSI ストリーム連携
- `herdr api snapshot|schema` — ソケット API のスキーマ・ランタイムスナップショット確認

## recipes

### サーバーを起動して準備完了を待つ

```bash
NEW_PANE=$(herdr pane split w1Z:p2 --direction right --no-focus | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
herdr pane run "$NEW_PANE" "npm run dev"
herdr wait output "$NEW_PANE" --match "ready" --timeout 30000
herdr pane read "$NEW_PANE" --source recent --lines 20
```

### 別 pane でテストを走らせて結果を確認する (一度きりのコマンド → `pane run` を使う)

```bash
NEW_PANE=$(herdr pane split w1Z:p2 --direction down --no-focus | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
herdr pane run "$NEW_PANE" "cargo test"
herdr wait output "$NEW_PANE" --match "test result" --timeout 60000
herdr pane read "$NEW_PANE" --source recent --lines 30
```

### 新しいエージェントを起動してタスクを与える (`agent start` を使う)

`agent send` は Enter を送らない (改行込みの `run` に相当するものが `agent` 系には無い) ので、Enter を送るには `pane send-keys` に切り替える必要があり、そのために `agent start` のレスポンスから pane id を読んでおく:

```bash
NEW_PANE=$(herdr agent start reviewer --split right --no-focus -- ${user_config.CLAUDE_COMMAND} | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["agent"]["pane_id"])')
herdr agent wait reviewer --status idle --timeout 15000
herdr agent send reviewer "review the test coverage in src/api/"
herdr pane send-keys "$NEW_PANE" Enter
```

### 他のエージェントと連携する

```bash
herdr wait agent-status w1Z:p1 --status done --timeout 120000
herdr pane read w1Z:p1 --source recent --lines 100
```

### git worktree を作って新しい workspace で作業する

```bash
herdr worktree create --workspace w1Z --branch feature/x --label "feature x" --no-focus
```

## notes

- `workspace list/create/get`, `tab list/create/get`, `pane list/get/split/current/layout/neighbor/edges/move`, `agent list/get/start`, `worktree list/create/open`, `wait output`, `wait agent-status` は成功時に JSON を出す。
- `pane read` は生テキストを出す (JSON ではない)。一方 `agent read` は JSON を出し、実際の内容は `result.read.text` にネストされている (実機で確認済み: `"format":"text"` というフィールドはレンダリング形式を示すだけで、出力自体が生テキストになるわけではない)。スクリプトから読み出すときはこの違いに注意する。
- `--format ansi` または `--ansi` で TUI フィードバックループ向けの ANSI レンダリングが取れる。
- `pane send-text` / `pane send-keys` / `pane run` / `agent send` は成功時に何も出力しない。
- 新しい id は `workspace create`・`tab create`・`pane split`・`pane move`・`agent start`・`worktree create` のレスポンスから読み取る。`workspace create` は `result.workspace` / `result.tab` / `result.root_pane`、`tab create` は `result.tab` / `result.root_pane`、`pane split` は `result.pane.pane_id`、`agent start` は `result.agent.pane_id` / `result.agent.terminal_id`。
- `--no-focus` は split / tab create / workspace create / worktree create で、自分のフォーカスを維持したまま新しいものを作るのに使う。
- `--label` を付けなければ workspace は cwd ベース、tab は番号ベースの名前になる。
- herdr の中で動いているなら環境変数 `HERDR_ENV` が `1` になっている。自分の pane/tab/workspace id は `HERDR_PANE_ID` / `HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` からも取れる (`HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` の staleness については罠を参照)。

## 罠

### 「フォーカスされている pane」と「自分の pane」は別概念

`pane list` の `focused` フィールドは UI 上どこにカーソルがあるかを示す状態で、それを「自分の pane」だと決め打ちしない。実機で確認済み: 自分の pane (`w1Z:p1`) から `herdr workspace focus w1X` で UI フォーカスを別 workspace に移した直後、同じ自分の pane から `herdr pane current` を実行しても `pane_id` は `w1Z:p1` のまま変わらず、`focused` フィールドだけが `false` になった (`pane list` 側では `focused:true` が w1X の pane に移っていた)。つまり `pane current` は UI フォーカスの状態に左右されず、常に呼び出し元の pane を返す。自分自身を特定するには `pane current` を使い、`focused` フィールドを自分の判定に使わないこと。

### `HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` は pane 起動時点のスナップショットで、`pane move` 後に古くなる

実機で確認済み: 新しい tab に pane を作り、その pane プロセスの `printenv HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` / `HERDR_PANE_ID` を控えておいてから、その pane を `herdr pane move --tab <別tab>` で移動した。移動後に同じプロセスで改めて `printenv` すると、`HERDR_PANE_ID` は正しい値のままだったが、`HERDR_TAB_ID` は移動前の tab id を返し続けた (workspace は変えていないので `HERDR_WORKSPACE_ID` は今回たまたま一致していたが、同じ理屈でワークスペースをまたぐ移動でも古くなるはず)。`HERDR_PANE_ID` は pane が生きている間は信頼できるが、`HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` を使うときは、自分が `pane move` されていないか (されている可能性があるなら `pane current` で問い合わせて上書きする方が安全) を意識すること。

### `agent wait` の `--status` は `wait agent-status` と選択肢が違う

`herdr agent wait <target> --status <idle|working|blocked|unknown>` — **`done` が無い**。「終わったがまだ見ていない」を待ちたいなら `herdr wait agent-status <pane_id> --status done` を使う (pane id 経由、target 経由ではない)。

### `agent start -- <argv>` はプロセス終了と同時に pane が消える

実機で確認済み: `herdr agent start test --split right --no-focus -- sleep 15` を実行すると、プロセスが動いている間は `agent get`/`agent read` で参照できるが、プロセスが exit した直後に pane は自動的に閉じ、以後同じ pane id / target を指定すると `pane_not_found` / `agent_not_found` になる。`pane run` 経由 (永続シェルにコマンド文字列を打ち込む方式) はシェルが生き残るのでこの挙動にならない。一度きりのコマンドの結果を後から読みたい場合は `pane split` + `pane run` を使うこと。

### `plugin` と `terminal` は独立したコマンドツリー

`plugin` と `terminal` は、トップレベル `herdr <subcommand>` usage には出てこない (`herdr --help` の一覧に載らない) が実際には存在する別ツリー。どちらも herdr 自身のローカルプラグイン管理・ブリッジプロセス向けで、このスキルの主眼であるコーディングエージェントの操作対象ではない。
