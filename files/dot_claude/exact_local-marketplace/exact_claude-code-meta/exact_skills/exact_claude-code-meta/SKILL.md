---
name: claude-code-meta
description: |
  CLAUDE.md / SKILL.md / `.claude/rules/*.md` を新規作成・更新・レビューするとき必ず参照する。Claude Code 本体のシステムプロンプト・組み込みスキル・ツール説明 (Piebald-AI から抽出した本体プロンプト一式) を references に同梱しており、新規・改訂内容が本体側の既存指令と冗長にならないようにする材料として使う。SKILL.md を編集する場合は、エージェントが学習データから知らない Claude Code 固有挙動 — プリプロセッシング、`${CLAUDE_SESSION_ID}` 等の文字列置換 — を理解した上で作業する。
---

# Claude Code 自身のメタ情報

CLAUDE.md / `.claude/rules/*.md` / SKILL.md を新規作成・更新・レビューするとき、Claude Code 固有の挙動を判断する。誤りやすい要点はこの SKILL.md 内に inline で持ち、本体プロンプトの出典が必要なときは同梱の references を参照する。

## 1. エージェントが特に誤解しやすい点

### `${CLAUDE_SESSION_ID}` は環境変数ではない

SKILL.md 内の `${CLAUDE_SESSION_ID}` は **スキルのレンダリング前に行われる文字列置換**。`env` 等で取得しようとしても存在しない。他に `${CLAUDE_SKILL_DIR}`、`$ARGUMENTS`、`$ARGUMENTS[N]` (短縮 `$N`)、`arguments` frontmatter で宣言した名前付き引数 `$name` がある。適用範囲は SKILL.md 本文のみ (frontmatter 内では置換されない)。

### SKILL.md のプリプロセッシング

SKILL.md 内の以下のような記法は、スキル呼び出し時にシェル実行され、出力で置換される。Claude は置換後のテキストのみを見る (= Claude が実行するわけではない)。

(以下の例に置ける `&#96;` はバッククォートを表している。このスキル文書自体も Claude によるプリプロセッシングの対象であるため。)

インライン:

```md
PR diff: !&#96;gh pr diff&#96;
```

複数行はフェンスコードブロック:

~~~md
&#96;&#96;&#96;!
node --version
git status --short
&#96;&#96;&#96;
~~~

落とし穴:

- **キャッシュなし**: スキル呼び出しのたびに毎回実行される
- **並列実行**: 複数コマンドは並列で動く。順序依存があるなら 1 つのブロックにまとめる
- **パーミッション**: 実行されるコマンドは `settings.json` の `permissions.allow` の影響を受ける
- **`allowed-tools` で Bash パターンは効かない** ([anthropics/claude-code#14956](https://github.com/anthropics/claude-code/issues/14956))。スキル frontmatter で `allowed-tools: Bash(git:*)` のようにしても本文内のこの記法には適用されない。`settings.json` の `permissions.allow` に追加する必要がある
- **無効化**: `settings.json` の `disableSkillShellExecution: true` で各コマンドが `[shell command execution disabled by policy]` に置換される (バンドル/管理スキルは影響を受けない)

## 2. Claude Code 本体のシステムプロンプト集 (references)

Claude Code CLI から抽出されたシステムプロンプト・ツール説明・組み込みスキルの一式を `${CLAUDE_SKILL_DIR}/references/claude-code-system-prompts/` に同梱している。CLAUDE.md / SKILL.md / `.claude/rules/*.md` を新規・改訂する際に、既存の指令と冗長にならないよう必要に応じて参照する。

主要な構造:

- `system-prompts/` — プロンプト本体 (約 280 ファイル)
- `CHANGELOG.md` — バージョンごとの変更点
- `tools/` — Piebald-AI 側の補助スクリプト

`system-prompts/` 配下のファイル名プレフィックスで種類が分かれる:

| プレフィックス | 内容 |
|---|---|
| `system-prompt-*` | メインシステムプロンプトの構成要素 |
| `system-reminder-*` | `<system-reminder>` で挿入されるリマインダ |
| `tool-description-*` | 各ツールの説明文 (Bash, Read, Write 等) |
| `agent-prompt-*` | 各エージェント (Explore, Plan mode 等) のプロンプト |
| `skill-*` | 組み込みスキル |
| `data-*` | 参照データ (Anthropic API リファレンス、モデルカタログ等) |
