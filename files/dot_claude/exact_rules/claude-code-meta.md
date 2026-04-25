---
paths:
  - "**/.claude/rules/*.md"
  - "**/.claude/skills/**/SKILL.md"
  - "**/CLAUDE.md"
---

# Claude Code 自身のメタ情報

CLAUDE.md / rules / SKILL.md を保守・新規作成するとき、Claude Code 固有の挙動 (paths のトリガー、評価タイミング、優先度、frontmatter キー、スキルの特殊構文、ライフサイクル等) を判断する。エージェントが標準知識として持っていない情報のため、誤りやすい要点を本ファイル内に inline で持ち、詳細は各 docs を参照する。

## エージェントが特に誤解しやすい点

### `${CLAUDE_SESSION_ID}` は環境変数ではない

SKILL.md 内の `${CLAUDE_SESSION_ID}` は **スキルのレンダリング前に行われる文字列置換**。`env` 等で取得しようとしても存在しない。他に `${CLAUDE_SKILL_DIR}`、`$ARGUMENTS`、`$ARGUMENTS[N]` (短縮 `$N`)、`arguments` frontmatter で宣言した名前付き引数 `$name` がある。適用範囲は SKILL.md 本文のみ (frontmatter 内では置換されない)。

詳細: `~/.claude/docs/skills.md` の「文字列置換」。

### HTML コメント `<!-- ... -->` は CLAUDE.md と SKILL.md で挙動が違う

| ファイル | ブロックレベル コメント | コードブロック内 | 出典 |
|---|---|---|---|
| CLAUDE.md | 削除されて Claude に届かない | 保持 | 公式 memory.md |
| SKILL.md | 保持されて Claude に届く | 保持 | 実機 v2.1.119 で検証 |

SKILL.md は **インラインコメント (テキスト中の `<!-- ... -->`) も同じく保持** される (実機 v2.1.119 で検証)。CLAUDE.md のインラインコメント挙動は本ドキュメントでは未検証 (公式 memory.md は「ブロックレベル」のみ言及)。

CLAUDE.md では人間専用メモをトークン消費なしで残せる。SKILL.md ではコメントもエージェントに届くため、トークンを消費する代わりに「人間とエージェント両方への注意書き」として機能する。

詳細: `~/.claude/docs/skills.md` の「HTML コメントの扱い」。

### `paths` frontmatter は Read 時のみ評価される

`paths` 付き rule はパターン一致するファイルを Read したときに発火する。`Write` 単体 (新規ファイル作成) では発火しない。新規ファイルを作るときは touch → Read → Write の 3 ステップを使う (`~/.claude/CLAUDE.md` の「新規ファイル作成プロトコル」に詳細)。

詳細: `~/.claude/docs/claude-code-rules.md` の「paths の評価タイミング」。

### `` !`...` `` は前処理であり Claude が実行するものではない

SKILL.md 内の `` !`<command>` `` および ` ```! ` フェンスブロックは、スキル呼び出し時にシェル実行され、出力で置換される。Claude は置換後のテキストのみを見る。指示文中で使うと指示自体が出力で置き換わり読めなくなる場合があるため、指示文と動的データは分離する。

詳細: `~/.claude/docs/skills.md` の「プリプロセッシング」。

## 仕組みの全体像

- rules ディレクトリの仕組み: `~/.claude/docs/claude-code-rules.md`
- スキルの仕組み: `~/.claude/docs/skills.md`
