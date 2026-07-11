---
name: ctx
description: ctx (https://ctx.rs/) を使ってコーディングエージェントのトランスクリプトを検索・参照するときに使う。「過去のセッションを調べて」「前にやった作業を確認して」「Claude Code セッションID xxx の内容を教えて」「あのときの経緯を教えて」と依頼されたときに必ず使う。
---

# ctx — agent history search

ctx は、過去の coding-agent セッション (Claude Code / Codex 等) から、フレーズ・ファイル名・ツール出力・エラーメッセージ・意思決定・機能名などを検索して引用付きで取り出すツール。要約や推論はせず、ヒットしたセッション/イベントをそのまま返す。主に次の2用途で使う:

- **作業前の裏取り**: 今のタスクに関係しそうな過去の意思決定・実行コマンド・失敗・引用元が、過去のセッションに残っている可能性があるとき
- **履歴調査レポート**: 「前にやった作業を確認して」「あのときの経緯を教えて」のように、過去のセッション横断でトピックを調査してまとめてほしいと頼まれたとき

## 0. ctx の前提知識

### ID 体系の概念

ctx には独立した3種類の ID がある:

| ID | 何か |
|---|---|
| `ctx_session_id` | ctx が内部で採番するセッションID |
| `ctx_event_id` | ctx が内部で採番するセッション内の1エントリ (1発言 / 1ツール呼び出し) のID |
| `provider_session_id` | Claude Code など元のツール自身が持つセッションID |

**この3つを混同してはいけない**。特に「Claude Code セッション ID を渡された」ときにそれを `ctx_session_id` だと思って位置引数に渡すと必ず失敗する:

```console
$ ctx show session <claude_code_session_id>
Error: session <claude_code_session_id> was not found; rerun the search that found it with --verbose to get ctx_session_id
```

### `search` / `show session` / `show event`

- `ctx search`: インデックス済みセッション横断でクエリにマッチする箇所を探す。既定ではセッションごとに最も強くヒットした一箇所を返し、スニペット・マッチ理由・関連度スコアに加え `ctx_event_id` / `ctx_session_id` / provider 情報 / タイムスタンプ / cwd / ファイルパスといったメタデータを添えて出す。
- `ctx show session`: 指定セッションの会話トランスクリプトを丸ごと返す。表示密度を切り替えられ、markdown としてファイルにも書き出せる。セッション全体の流れを追うとき用。
- `ctx show event`: セッション内の 1 イベント (1 発言 / 1 ツール呼び出し) を、前後のイベントを窓として添えてピンポイントで返す。`search` で当たった箇所を裏取り・引用するとき用。

いずれもモデルによる要約は挟まず、インデックス済みトランスクリプトから決定的に取り出した内容をそのまま返す。

## 1. import — 最初に必ず実行する

ctx は、ソースが大きい場合や既にカタログ済みのインデックスに対してはフォアグラウンドでのキャッチアップスキャンを省略し、エラーも出さずに古いインデックスのまま検索結果を返すことがある。**最初に必ず `ctx import --all` を実行する** ことを徹底する。

```bash
ctx import --all
ctx ...
```

## 2. `provider_session_id` (Claude Code セッション ID) から `ctx_session_id` を求める

`ctx sql` で次のように実行する:

```console
$ ctx sql "SELECT ctx_session_id FROM ctx_sessions WHERE provider_session_id = '<claude_code_session_id>'"
ctx_session_id
------------------------------------
<ctx_session_id>
```

## 3. `ctx search`

インデックス済みセッションを横断して自然言語クエリでヒットを取り出す主要コマンド。要約や推論はせず、マッチしたイベントをメタデータ付きでそのまま返す。

### 何が返るか (既定: セッション多様モード)

引数なしオプションのみで実行すると **セッションごとに最も強くヒットした 1 イベントだけ** を rank 順に並べて返す。同じセッションからのヒットは 1 件に集約されるため、"どのセッションが関連するか" を俯瞰したいとき向き。1 件の出力は次の要素から成る:

```
1. claude assistant message - 4c32cd94-7306-4344-a412-173b72f800b6
   claude | importance 1.00 | session 9b1ef3c8 | event d745ec44 | 2026-07-09T14:54:12.624+00:00
   chezmoi が「`.bashrc` が chezmoi 管理外で変更されている」と検知して TTY プロンプトを要求してるけど…
   inspect: ctx show event d745ec44-cb77-76bf-b4d8-041aedb16f90 --window 10
```

- 1 行目: イベント種別 (`message` / `tool call` / `tool output` 等) と `provider_session_id`
- 2 行目: provider・`importance` (0〜1)・`ctx_session_id` prefix・`ctx_event_id` prefix・タイムスタンプ
- 3 行目以降: マッチ箇所のスニペット (前後は自動で切り詰められる)
- `inspect:` 行: そのイベントを裏取りするための `ctx show event` コマンド

**メタデータに出るのは prefix のみ**。フル ID を得たいときは `--verbose` を付ける (下記)。

### `--events` — 同一セッションから複数イベントを返す

既定ではセッション単位で 1 件だが、`--events` を付けると **セッション制約を外して純粋に rank 順の event 列** を返す。同じセッションから複数イベントが並ぶことがあり、"この話題を誰が何回言及したか" のような密度が見たいときに使う:

```console
# 既定: 5 件とも異なるセッション
$ ctx search "chezmoi" --limit 5
1. ... session 9b1ef3c8 | event d745ec44 ...
2. ... session 61e312aa | event 114ce93b ...
3. ... session e83b7828 | event 0402fc1d ...
4. ... session 075fdbbc | event 0d08c0b5 ...
5. ... session b3d22081 | event 01560cc5 ...

# --events: session 9b1ef3c8 から 2 件返っている
$ ctx search "chezmoi" --limit 5 --events
1. ... session 9b1ef3c8 | event d745ec44 ...
5. ... session 9b1ef3c8 | event 0fe1eb2f ...
```

### `--session <ctx-session-id>` — 1 セッション内の event を rank 順に取り出す

セッション ID (フル or 8 文字以上の prefix) を渡すと、そのセッション内だけで rank 上位の event を返す。既定の "多様モード" ではなく **event 単位** で返るので、当該セッション内でクエリがどう展開されたかを追える。既定検索で当たったセッションを深掘りするときに使う:

```console
$ ctx search "chezmoi" --session 9b1ef3c8 --limit 3
1. ... session 9b1ef3c8 | event d745ec44 | rank 1.00 ...
2. ... session 9b1ef3c8 | event 0fe1eb2f | rank 0.92 ...
3. ... session 9b1ef3c8 | event cb277377 | rank 0.81 ...
```

### `--term <query>` — 検索範囲を OR で広げる

繰り返し指定可。**必須語ではなく "どれか含めば拾う"** (OR 結合)。関連語・エラーメッセージの断片・同義語などをまとめて投げて 1 セッションでも見落とさないようにするためのフラグ。`AND` 相当の絞り込みは無い:

```bash
ctx search "chezmoi" --term "brew" --term "apt"
```

### `--verbose` — フル ID と follow-up コマンドを出す

既定出力は prefix のみだが、`--verbose` で 1 ヒットごとにフル ID・引用元・次に打つべきコマンドが列挙される:

```
claude assistant message - 4c32cd94-7306-4344-a412-173b72f800b6
  ctx_event_id: d745ec44-cb77-76bf-b4d8-041aedb16f90
  ctx_session_id: 9b1ef3c8-5646-7033-b0f8-131337579934
  provider_session_id: 4c32cd94-7306-4344-a412-173b72f800b6
  source_format: claude_projects_jsonl_tree
  ...
  rank: 1.00
  next: ctx show session 9b1ef3c8-5646-7033-b0f8-131337579934
  next: ctx show event d745ec44-cb77-76bf-b4d8-041aedb16f90 --window 10
  next: ctx search chezmoi --session 9b1ef3c8-5646-7033-b0f8-131337579934
  citation: event d745ec44-cb77-76bf-b4d8-041aedb16f90
  citation: session 9b1ef3c8-5646-7033-b0f8-131337579934
```

引用・resume・スクリプトへの受け渡しなど「prefix では足りない用途」に必要な情報が揃う。逆に日常の検索では出力量が増えて読みにくくなるので、絞り込みが済んでから付ける。

### 絞り込みフラグ

いずれもクエリと組み合わせて検索範囲を狭める。フラグ単体では検索できない (`--file` を除き、クエリ or `--term` or `--file` の少なくとも 1 つが必要)。

- `--provider <name>` — provider を 1 つに絞る (`claude` / `codex` / `cursor` など)
- `--workspace <text>` — 保存済み workspace / cwd / source path / リポジトリ名に対する部分一致。**Claude Code のセッションを絞るときは、cwd の生パスではなく `~/.claude/projects/` 以下の project dir 名に合わせた値を渡す** (cwd の生パスは索引に残っておらず、`.dotfiles` のような値は当たらない)。project dir 名は Claude Code が cwd をエンコードしたもので、`.` が `-` に置換される (例: cwd `/home/m-takeda/.dotfiles` → project dir `-home-m-takeda--dotfiles`)。また値の先頭が `-` になると clap にフラグとして喰われて黙って空返しになるため、この形式では等号必須:

  ```bash
  ctx search "zsh" --workspace=-home-m-takeda--dotfiles
  ```
- `--since <duration|rfc3339>` — 直近に絞る。`30d` のような日数、または `2026-06-01T00:00:00Z` のような RFC3339
- `--event-type <type>` — `message` / `tool_call` / `tool_output` / `command_started` / `command_output` / `command_finished` / `file_touched` / `vcs_change` / `artifact` / `summary` / `notice` のいずれかに限定
- `--file <path>` — インポート時に記録された "触れたファイルパス" のメタデータで絞る。**現在のファイルシステムは見ない**。クエリ無しで単独指定も可 (そのファイルに触れたセッション一覧が出る)
- `--include-subagents` — 既定は primary エージェントのセッションのみ。サブエージェント (実装詳細・レビュー・テスト出力等) も対象にしたい場合に付ける
- `--limit <n>` — 既定 20、最大 200

### `--json` — スクリプト用の機械可読出力

`jq` やパイプで正確なフィールド抽出をするときだけ使う。テキスト出力より情報量が多くトークンを大量に消費するため、エージェントが読む用途では既定のテキスト出力を選ぶ。

### 使い分けの目安

- "この話題に触れたセッションを俯瞰したい" → 既定 (session-diverse)
- "既定検索で当たったセッションをもっと深く読みたい" → `--session <id>` で event 列
- "同一セッションでの言及回数・密度を見たい" / "全セッション横断で dense に event を並べたい" → `--events`
- "関連語も一緒に投げたい" → `--term` を繰り返す
- "引用・resume に使うフル ID が要る" → `--verbose`

## 4. `ctx show session`

指定した 1 セッションの会話トランスクリプトをまるごと復元する。`search` が「どのセッションが関係ありそうか」を絞るためのコマンドなのに対し、`show session` は「そのセッションで実際に何が起きたか」を通しで読むためのコマンド。モデルによる要約は挟まらず、インデックス済みイベントを決定的に並べ直して返す。

引数はセッション ID (フル or 8 文字以上の prefix)。位置引数は `ctx_session_id` 前提で、`provider_session_id` (Claude Code セッション ID) をそのまま渡すと `was not found` エラーになる。手元にあるのが Claude Code セッション ID だけのときは、次のどちらかで引ける:

- **`--provider` + `--provider-session` で直接引く**: SQL 変換を省略できる正規ルート。ヘッダーに対応する `ctx_session_id` が入って返るので、後段のコマンド (`ctx show event` など) に渡す ID もそこから拾える。

  ```bash
  ctx show session --provider claude --provider-session <claude-code-session-id> --mode lite
  ```

- **2 節の SQL で先に `ctx_session_id` を求めてから位置引数で渡す**: 他コマンドと ID を共有したい・スクリプトで使い回したいとき向き。

### `--mode` — トランスクリプトの粒度

同じセッションでも、どのイベント種別まで復元するかで出力量が桁で変わる。用途に合わせて選ぶ:

- **`lite`** (既定): 各ターンについて、user message と assistant の **最終** message だけを残す。tool_call / tool_output や、tool_use を挟む中間の assistant message、`notice` (attachment / mode 変更等の system 系イベント) は落ちる。「何を頼んで何が返ったか」を最短で追いたいときの既定値。
- **`full`**: user/assistant/system の **message イベントを全部** 残す。lite からさらに、tool_use を含む中間の assistant message や、`content_preview` に生 JSON が入っている thinking イベントも入る。tool_output / command / notice は落ちる。ターン内部での「思考 → tool 呼ぶ → 結果を受けて次を書く」の流れまで読みたいとき用。
- **`log`**: インポート済みの **全イベント** (tool_call / tool_output / command_* / notice / attachment / file_touched 等) を時系列順で出す。「そのセッションで実際に何のコマンドをどんな引数で叩いたか」まで再現したいときに使う。ただし後述の通り最も膨らむ。

同じセッション (Claude Code 側 433k tokens、event 内訳: `message` 300 / `tool_call` 193 / `tool_output` 193 / `notice` 385) を全モード × 全フォーマットで書き出したときの実測サイズ (実行して確認済み):

| mode  | text        | markdown    | json         | jsonl        |
| ----- | ----------- | ----------- | ------------ | ------------ |
| lite  | 136 KB /  1506 行 | 138 KB /  1717 行 | 240 KB /  1996 行 | 238 KB /   70 行 |
| full  | 327 KB /  2235 行 | 334 KB /  3136 行 | 758 KB /  8436 行 | 753 KB /  300 行 |
| log   | 697 KB /  4558 行 | 722 KB /  7772 行 | 2.2 MB / 29730 行 | 2.2 MB / 1071 行 |

`log` は `lite` の 5 倍前後に膨らむ。**必要な粒度で最小のモードを選ぶ**のが原則。tool 引数まで見たいときだけ `log` を選び、それ以外は `lite` / `full` で足りる。

### `--format` — 出力表現

いずれのモードでも 4 種類から選べる。

- **`text`** (既定): 人間・エージェントが読む用の平文。冒頭に `ctx_session_id` / `provider` / `provider_session_id` / `mode` / `format` / `source_path` を並べたヘッダーが付き、以降は `[timestamp] role type <event_id>` + 本文の順で 1 イベントずつ並ぶ。
- **`markdown`**: 見出し・整形付き。`--out foo.md` で人間や他エージェントに渡す成果物を作るとき用。
- **`json`**: 1 つの JSON オブジェクトに全イベントを内包する。フィールドを機械的に取り出したいとき用。
- **`jsonl`**: 1 行 1 イベント。**行数 = イベント数** になるので、`grep` / `jq` / `awk` で「user 発言だけ」「Bash tool_call だけ」のように切り出すのに向く。

### `--out` — ファイル書き出し (パイプ回避も兼ねる)

`--out <path>` を付けると、レンダリング結果はそのパスへ書き出され、stdout には何も出ない (成功時)。用途は 2 つ:

- **パイプの Broken pipe panic (6 節) を避ける**: `show session` は他サブコマンドと違い `--out` を持つので、`| head` のようにレース経路を挟まずに直接ファイルへ落とせる。
- **大きな出力を Read / grep で扱う**: 上表の通り `full` / `log` はメインコンテキストに丸ごと乗せられないサイズになりやすい。ファイルに落としてから読む方が扱いやすい。

`--out` を付けない場合は stdout に流れる。当該セッションが小さい (lite で 100 KB 未満程度) と分かっていて、そのままメインコンテキストに乗せて読みたいときだけ省略する。

### 大きすぎるセッションを扱う

**まずサイズを見積もる**。`ctx_events` ビューを叩けばイベント種別ごとの件数が引ける:

```console
$ ctx sql "SELECT event_type, COUNT(*) AS n FROM ctx_events \
    WHERE ctx_session_id = '<ctx-session-id>' \
    GROUP BY event_type ORDER BY n DESC"
event_type  | n
----------- | ---
notice      | 385
message     | 300
tool_output | 193
tool_call   | 193
```

`message` 中心なら `lite` / `full` で足りる。`tool_call` / `tool_output` が多くて中身を見たいなら `log` が必要になる、といった判断ができる。

**ファイルに落として絞り込む**。全体は乗らないが特定の話題だけ拾いたい、というときは jsonl で書き出して `jq` / `grep` で切ってから Read する。jsonl の各行はトップに `ctx_session_id` / `provider` などのセッションメタが並び、イベント本体は `.event` にネストされる (`.event.event_type` / `.event.role` / `.event.text` など)。

```console
$ ctx show session <ctx-session-id> --mode log --format jsonl --out /tmp/ctx-session.jsonl

# user が発言した時刻の列 (会話の切れ目を掴む)
$ jq -r 'select(.event.event_type=="message" and .event.role=="user") | .event.occurred_at' \
    /tmp/ctx-session.jsonl | head -3
2026-07-09T16:18:00.511Z
2026-07-09T16:21:43.033Z
2026-07-09T16:25:44.272Z

# 気になった 1 件の本文だけ抜く (search の --verbose や上の一覧で拾った prefix で絞る)
$ jq -r 'select(.event.ctx_event_id | startswith("ca69e813")) | .event.text' \
    /tmp/ctx-session.jsonl
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

# Bash ツール呼び出しの回数を数える (tool_call event の .event.text は "tool call: <name>")
$ grep -c '"text":"tool call: Bash"' /tmp/ctx-session.jsonl
135
```

セッション全体の会話を通しで読むなら jsonl を絞るより `--mode lite --format text` の方が向く。jsonl 経由は「特定イベントだけ機械的に取りたい」ときの手段。

**サブエージェントに読ませる**。ファイルに落としたトランスクリプトを `Explore` や `general-purpose` エージェントに渡し、要約だけメインに返させると、生ログでコンテキストを埋めずに済む。

### `--quiet`

インポートの status メッセージなど、非必須のセットアップ出力を stderr に出さない。パイプ / スクリプト用途で邪魔なとき付ける。`CTX_QUIET=1` でも同じ効果。

## 5. `ctx show event`

セッション内の 1 イベント (1 発言 / 1 ツール呼び出し / 1 notice など) を、前後の隣接イベントを窓 (window) として添えて返すコマンド。`ctx search` で当てた 1 点を裏取り・引用したいとき、および「そのイベントの直前・直後に何が起きていたか」だけを見たいときに使う。`ctx show session` のようにセッション全体を復元せず、1 点にピンポイントで寄れる。

引数は `ctx_event_id` (フル UUID もしくは 8 文字以上の hex prefix)。`provider_event_id` は受け付けない。

### 引数エラー

- prefix が 8 文字未満: `event id prefix must be at least 8 hex characters, or pass a full ctx UUID`
- prefix でも UUID でもない形式: `event id must be a full ctx UUID or an unambiguous hex prefix from verbose search output`
- 存在しない ID: `event <id> was not found; rerun the event search with --events --verbose to get ctx_event_id`

### `--before` / `--after` / `--window` — 隣接イベントの窓

- `--before N`: 対象の **N イベント前まで** を並べる (既定 0)
- `--after N`: 対象の **N イベント後まで** を並べる (既定 0)
- `--window N`: `--before N --after N` のシノニム

`--window` と `--before` / `--after` を同時に指定した場合、`--window` の値で両側とも上書きされる (実行して確認済み: `--window 2 --before 5` の結果は前後 2 件ずつ)。

窓の並べ順は **時刻ではなくセッション内のイベント順序 (`event_seq`)** で決まる。ヘッダーに出るタイムスタンプが不揃いに見えるのはこのため。例:

```console
$ ctx show event ac626e5d --before 3 --after 0
...
[2026-07-09 16:12:21.353 UTC] unknown notice ddffe8a9-06da-7b32-b6fc-fa3d9cefb471
[2026-07-09 16:12:21.354 UTC] unknown notice 9b7d3f7c-5831-7f31-ab04-2955f5dd5f66
[2026-07-09 17:05:45.860 UTC] unknown notice a3ea3d6f-2e0e-7cc0-823e-e6d52c193763
[2026-07-09 16:18:00.511 UTC] user message ac626e5d-2325-7e87-871c-e8f639bbc348
```

さらに、窓に入る隣接イベントは **event_type で絞られない**。Claude Code のセッションは `notice` (attachment / file-history-snapshot 等の system 系イベント) が `message` を桁で上回ることが多く、`--window 5` を指定しても 10 個並んだイベントが全部 notice で assistant の応答が 1 件も入らない、ということが普通に起こる。「user prompt の次の assistant 応答が見たい」ような場合は `--after` を大きめに取る (例: `--after 20`) か、`ctx sql` で `event_type='message'` に絞って直近の assistant イベントを別途引く方が確実。

### `--format` — 出力表現

`text` (既定) / `markdown` / `json` / `jsonl` の 4 種類。`ctx show session` と同じセマンティクスで、`text` はヘッダー (`ctx_event_id` / `ctx_session_id` / `provider` / `provider_session_id`) の下に `[timestamp] role type <event_id>` + 本文が並ぶ。`markdown` はセクション見出し付きで人間や他エージェントに渡す用。`jsonl` は 1 行 1 イベントで、`jq` で `.event_type` / `.role` / `.text` などのフィールド抽出に向く。

**`--out` は存在しない** (`ctx show session` にしかない)。大きな出力をファイルに落としたいときはシェルリダイレクト `> path` を使う。パイプで `| head` する場合は 6 節の Broken pipe 対策に従う (`--window` を小さくして分量を絞る / `2>/dev/null` で panic ログを潰す / 一旦リダイレクトしてから読む)。

### 使い分けの目安

- **`search` のヒット 1 件を裏取りしたい**: `--window 3〜5` 程度で前後の文脈を短く添える。搭載されるスニペットは切り詰められているので、全文はここで確認する。
- **user prompt に対する assistant の返答だけ見たい**: `--after N` を非対称に大きく取る (notice が挟まるため 20〜50 は必要になる)。もしくは `ctx sql` で `event_type='message'` に絞ってから隣接 event を狙う。
- **セッション全体の流れを追いたい**: `ctx show event` ではなく `ctx show session` を使う (4 節)。

## 6. 落とし穴: パイプ接続時の `Broken pipe` panic (全サブコマンド共通)

`ctx {search,show session,show event} ... | head` のように **出力を途中で打ち切るコマンドへパイプで繋ぐと、ctx が `Broken pipe (os error 32)` で panic して exit code 101 で終了する**。`ctx show session` に限った話ではなく、`ctx search` / `ctx show event` でも同じ (実行して確認済み: `search --limit 200 | head -3` で 5/5、`show event --window 50 | head -3` で出力サイズ次第でも発生)。

- **決定的ではなくレース**: ctx が全出力を書き終える前に reader が pipe を閉じると発生する。出力が大きいほど発生確率が高く、小さい出力 (~800B) でも稀に起こる (`search --limit 2 | head -3` を 5 回試して 1 回 panic)。
- **真因**: Rust 標準ライブラリが SIGPIPE を `SIG_IGN` にするデフォルトを採用しているため、stdout への write が EPIPE を返し、それを println! 系マクロが panic に変換する。ctx 固有バグではなく、opt-out していない Rust 製 CLI で広く起こる挙動。
- **データは無傷**: reader が pipe を閉じる前に受け取った stdout の内容は正しい (実行して確認済み)。panic は書き込み後の後始末で起きるノイズ。**`set -o pipefail` を有効にしていなければ実害は少ない** が、pipefail 下では非ゼロ終了が伝播してスクリプトを壊す。

### 回避策 (サブコマンドごと)

`--out` は `ctx show session` にしか無いため、コマンドによって手段が違う (実行して確認済み)。

- **`ctx show session`**: `--out <file>` でファイル出力にする。パイプを経由しないので panic は起きない。

  ```bash
  ctx show session <id> --mode lite --out /tmp/ctx-session.md
  ```

- **`ctx search` / `ctx show event`**: `--out` は無い。次のいずれかで対処する:
  - **出力を ctx 側で絞る**: `ctx search` なら `--limit <n>`、`ctx show event` なら `--window <n>` を小さく指定して reader が読み切れる分量にする (レースを縮めるだけで消せはしない)。
  - **stderr を潰して exit code を許容する**: `2>/dev/null | head -N` すれば panic のログは消え、head が受け取った stdout は正しい。`set -o pipefail` を使わなければ実質使える。
  - **一旦ファイルに落としてから読む**: 大きな出力を再利用したいときは `> /tmp/xxx` にリダイレクトしてから `head`/`grep`/Read ツールで読む。

  ```bash
  # レースを避けたい: ctx 側で分量を絞る
  ctx search "<query>" --limit 10
  ctx show event <id> --window 10

  # panic は許容して stdout だけ取る (pipefail オフ限定)
  ctx search "<query>" --limit 200 2>/dev/null | head -20

  # 使い回すならファイルに落とす
  ctx search "<query>" --limit 200 > /tmp/ctx-search.txt
  ```

## 8. 検索ワークフロー

1. 検索前に `ctx import --all` を実行する (5節)。

2. 自然言語で検索する:

   ```bash
   ctx search "<query>"
   ctx search "<query>" --provider claude
   ctx search "<query>" --workspace <workspace>
   ctx search "<query>" --file <path>
   ctx search "<query>" --since 30d
   ctx search "<query>" --term "<related term>" --term "<error text>"
   ctx search "<query>" --session <ctx-session-id>
   ctx search "<query>" --verbose
   ```

   エージェント可読性のため既定はテキスト出力。`--json` は `jq`/スクリプトに渡すときだけ使う (出力が大きくトークンを食う)。
   トピック横断のレポートが必要なら語句・フィルタを変えて複数回検索する。実装詳細・レビュー・テスト結果までカバーしたいときは `--include-subagents`。

   `--verbose` で ctx ID・provider ID・引用・follow-up コマンドをフルで得られる。

3. ヒットを鵜呑みにせず裏取りする:

   ```bash
   ctx show event <ctx-event-id> --window 5
   ```

   セッション全体の流れを追う必要があるときは、裸の `ctx show session <id>` ではなく 7 節の手順 (サイズ計測 → 必要なら絞り込み) に従う。

4. 出典や resume 用の情報が要るとき (4節参照):

   ```bash
   ctx locate event <ctx-event-id>
   ctx locate session <ctx-session-id>
   ```

5. 人間や他エージェントにファイルとして渡すとき:

   ```bash
   ctx show session <ctx-session-id> --format markdown --out <output-path>
   ```

## 9. Citation / Safety

- 回答や実装に影響したctx由来の材料は必ず引用する。provider・ctx session ID・(可能なら) ctx event ID・provider session ID・出典パスを含める。
- 複数の断片を統合した結論は「自分の統合である」と明示する。引用元がその結論を明示的に述べていない限り、ctxが決定を下したかのように書かない。
- 生トランスクリプト・大きなJSON・secrets・トークン・私的パスをユーザー向けレポートに貼らない。要約し、根拠として必要な範囲だけ短く引用する。
- `~/.local/state/ctx`、provider のトランスクリプトパス、JSON出力は、ユーザーが明示的に共有を求めない限りプライベートなローカル履歴として扱う。
