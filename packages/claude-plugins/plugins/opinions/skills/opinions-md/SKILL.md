---
name: opinions-md
description: ワークスペース内における過去の Claude Code 対話ログ (ctx が索引した全 primary セッション) から、ユーザーの durable な意見・信念・判断基準を蒸留して OPINIONS.local.md を生成する。
---

# OPINIONS.local.md ジェネレータ

過去の Claude Code 対話ログを唯一のソースに、ユーザーの durable な意見・信念だけを蒸留して、今のワークスペース向けの `$WORKSPACE/.claude/OPINIONS.local.md` を書く。

## 前提

- `ctx` CLI がセットアップ済みで、過去セッションを索引していること (`ctx-agent-history-search` スキルと同じ CLI)。未導入なら先にそちらを立ち上げる。
- `WORKSPACE` を決める。成果物 (local 版) の唯一の置き場所であり、既定で `$WORKSPACE/.claude/OPINIONS.local.md` に書く:

  ```bash
  WORKSPACE="$(git rev-parse --show-toplevel)"
  ```

  ワークスペースが git 管理下にない場合はユーザーに配置先を確認する (`git rev-parse` は非 git ディレクトリではエラー終了する)。
- 中間成果物 (バッチ台帳・抽出候補・ドラフト) はワークスペースに残す必要がないため `mktemp -d` で作った一時ディレクトリに置く。以降このパスを `$OUT` と書く:

  ```bash
  OUT="$(mktemp -d -t opinions-md)"
  ```

  `mktemp -d` は毎回新規の衝突しないディレクトリを作る (同名ワークスペースやブランチ併走との衝突を避けるため、固定パスにはしない)。中断した続きから再開したい場合は、直前に使っていた `$OUT` のパスをユーザーに確認して変数に入れ直す。

## 手順

### フェーズ 0: 準備とスコープ確認

1. ctx の準備を確認する。

   ```bash
   ctx status
   ctx sql "SELECT is_primary, COUNT(*) AS sessions FROM ctx_sessions GROUP BY is_primary"
   ```

2. **抽出源のスコープをユーザーに確認する。** 既定は **primary セッションのみ**。理由: ユーザー本人の発言 (意見の主源泉) は primary の user メッセージにしか無く、subagent セッションはエージェント同士のやり取りなので本人は喋っていない。primary だけで本人発話は全網羅でき、coverage は落ちない。
   - 「subagent 内で systemReminder 経由等に述べた指示・信念も拾いたい」意図があるなら `is_primary` 条件を外して全セッションを対象にする。この差分だけ確認して進める。

3. **出力先を確認する。** 既定は `$WORKSPACE/.claude/OPINIONS.local.md`。まず `$OUT/OPINIONS.draft.md` (中間ドラフト) に出し、ユーザーの確認後に配置する一段クッションを挟む。`$WORKSPACE/.claude/OPINIONS.local.md` に既存ファイルがある場合は上書き前に必ず退避を確認する (不可逆)。

### フェーズ 1: バッチ台帳を作る (メイン, 軽い)

primary セッションを event 数付きで CSV に吐き、event 数で均等割りして 16 バッチに分ける。

```bash
mkdir -p "$OUT/batches" "$OUT/candidates"
# primary セッションを event 数降順で CSV 化 (--max-rows で 100 行キャップを回避)
ctx sql --max-rows 1000 --format csv \
  "SELECT s.ctx_session_id,
          COUNT(e.ctx_event_id) AS events,
          SUM(CASE WHEN e.event_type='message' THEN 1 ELSE 0 END) AS msgs,
          COALESCE(s.cwd,'') AS cwd
   FROM ctx_sessions s
   LEFT JOIN ctx_events e ON e.ctx_session_id = s.ctx_session_id
   WHERE s.is_primary = 1
   GROUP BY s.ctx_session_id
   ORDER BY events DESC" > "$OUT/sessions.csv"
echo "rows (incl header): $(wc -l < "$OUT/sessions.csv")"

# event 数で LPT bin-packing して batch-01..16.txt を生成
python3 "${CLAUDE_SKILL_DIR}/scripts/build-batches.py" "$OUT" 16
```

補足:
- `--max-rows 1000` を忘れると `ctx sql` が 100 行で頭打ちになり、セッションを取りこぼす。
- バッチ数 16 は 369 セッション規模での実績値。セッション数に応じて `build-batches.py` の第 2 引数で調整してよい (1 バッチ ~20-25 セッションが目安)。

### フェーズ 1.5: パイロット (推奨)

いきなり 16 体流す前に batch-01 を 1 体だけ走らせ、出力 JSON のスキーマ・quote の質・件数感を確認する。ここで確認するスキーマは `opinion-extractor.md` の「出力」節が正本。抽出方針の調整が要る場合は、`opinion-extractor.md` 自体は編集せず、フェーズ 2 以降の Agent 呼び出しプロンプトに調整指示を追記して渡す (例: 「テーマ `<X>` は抽出しすぎなので confidence low 以下は落として」)。

```bash
python3 -c "import json;d=json.load(open('$OUT/candidates/batch-01.json'));print('valid,',len(d),'items');[print(x['confidence'],'|',x['theme'],'|',x['opinion']) for x in d[:6]]"
```

### フェーズ 2: 抽出 (サブエージェント fan-out)

各バッチ 1 体、同梱のカスタムエージェント `opinions:opinion-extractor` (`subagent_type: "opinions:opinion-extractor"`) を起動する。プロンプトには次を含める:

- ユーザー名 (例: `m-takeda`)
- 担当バッチファイルのパス (`$OUT/batches/batch-NN.txt`)
- 出力先パス (`$OUT/candidates/batch-NN.json`)
- (フェーズ 1.5 で抽出方針の調整が要ると分かった場合) その調整指示。全バッチ共通で効かせたいので、この後の全 Agent 呼び出しに毎回同じ指示を含める

`run_in_background: true` で並列に流す。マシン負荷を見つつ 3-5 体ずつラウンドで回してもよい。各エージェントは担当セッションを自分の context 内で読み、`$OUT/candidates/batch-NN.json` を書き、返り値の仕様は `opinion-extractor.md` の「返り値」節を参照。

全バッチの完了を待ってから、`ls "$OUT"/candidates/batch-*.json | wc -l` で `batches/` のバッチ数と一致するか確認する。欠けているバッチがあれば、そのバッチだけ同じ手順で再実行する。

### フェーズ 3: 集約と検証 (メイン, 軽い)

全候補 JSON をバリデートし、1 ファイルに集約してテーマ分布を出す。`alias` 辞書は実行のたびに実際に出た表記ゆれを見て育てる想定 (`opinion-extractor.md` の theme 例と語彙が乖離していないか、このタイミングで見ておく)。

```bash
python3 - "$OUT" <<'PY'
import json, os, sys, glob
from collections import Counter
out = sys.argv[1]
allc = []
for p in sorted(glob.glob(os.path.join(out, 'candidates', 'batch-*.json'))):
    b = os.path.basename(p).replace('.json', '')
    try:
        d = json.load(open(p))
    except Exception as e:
        print('BAD JSON:', p, e); continue
    for x in d:
        x['_batch'] = b
        allc.append(x)
# テーマ表記ゆれを寄せる
alias = {'命名哲学':'設計哲学', 'トラブルシューティング':'トラブルシュート',
         'データ基盤':'データ基盤/パイプライン', 'データ基盤・パイプライン':'データ基盤/パイプライン'}
for x in allc:
    x['theme'] = alias.get((x.get('theme') or '').strip(), (x.get('theme') or '').strip())
json.dump(allc, open(os.path.join(out, 'all-candidates.json'), 'w'), ensure_ascii=False, indent=1)
print('total candidates:', len(allc))
print('--- theme ---')
for t, c in Counter(x['theme'] for x in allc).most_common():
    print(f'{c:3d}  {t}')
print('--- confidence ---')
for t, c in Counter(x.get('confidence') for x in allc).most_common():
    print(f'{c:3d}  {t}')
print('contested:', sum(1 for x in allc if x.get('contested')))
PY
```

### フェーズ 4: 統合・執筆 (メイン, 品質勝負)

`$OUT/all-candidates.json` **だけ** を読み込む (生ログは読まない)。次を行い `$OUT/OPINIONS.draft.md` に日本語で書く:

- **重複マージ**: 同じ信念が複数バッチに出るのは強いシグナル。1 項目にまとめ、Evidence を束ねる。
- **テーマ分類**: theme を束ねて `##` セクションにする。対話が偏っているドメイン (例: 特定のドメイン固有の分野) は独立セクションにしてよい。
- **durable フィルタ**: low confidence 由来で一時的苛立ち・その場限りに見えるものは落とす。無理に項目数を増やさない。
- **drift/contested の扱い**: `contested: true` や矛盾する候補は、撤回・変遷として書くか落とすかを判断する。
- **Evidence 行**: 各項目に、その信念が表れた対話への参照 (ctx session ID + 本人発話の短い引用) を付す。quote は候補 JSON のものをそのまま使い、捏造しない。

書式の目安 (実績のドラフト構成):

```markdown
# OPINIONS.md

<一文の位置づけ>

<このファイルが何を蒸留したものか。ソース = ctx 索引の primary セッション N 本、
落としたもの = 一回限りの指示・コード片・雑談、である旨>

> 蒸留元の時期・分野の偏りに関する断り書き

---

## <テーマ>

### <一文で言い切った信念>

<補足 2-4 文。なぜそう考えるか、どの文脈で繰り返し現れたか>

- Evidence: 「本人発話の引用」(`<ctx_session_id 先頭8桁>`)
- Evidence: ...
```

### フェーズ 5: 確認と配置

ドラフトができたら、次の 3 点をユーザーに確認する:

1. **中身の妥当性** — 「これは自分の信念じゃない/言い過ぎ」があれば直す。
2. **粒度** — 項目数は多すぎ/少なすぎないか。ブログ原典は各テーマ数項目なので絞る方向もある。
3. **配置** — OK なら `$OUT/OPINIONS.draft.md` を `$WORKSPACE/.claude/OPINIONS.local.md` へ配置する (`mkdir -p "$WORKSPACE/.claude"` してから)。この local 版が `opinions-md-dotfiles` スキルの入力になる。

## 中間成果物 (すべて `mktemp -d` で作った `$OUT` に残す。ワークスペースには置かない)

- `sessions.csv` — primary セッション一覧 (event/msg 数付き)
- `batches/batch-NN.txt` — バッチごとのセッション ID 列
- `candidates/batch-NN.json` — 各バッチの抽出候補
- `all-candidates.json` — 集約済み候補 (統合フェーズの入力)
- `OPINIONS.draft.md` — 配置前のドラフト

## このスキルに同梱するもの

- `scripts/build-batches.py` — CSV を event 数で 16 均等割りするビンパッカー
- `opinions:opinion-extractor` (プラグイン同梱カスタムエージェント) — フェーズ 2 の抽出サブエージェント本体
