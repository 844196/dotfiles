# Claude Code rules ディレクトリ

`~/.claude/rules/` (ユーザー) および `<project>/.claude/rules/` (プロジェクト) は CLAUDE.md と並ぶ公式機能。指令を複数ファイルに分割して整理し、ファイルパスでスコープすることもできる。

以下、「memory.md」は公式ドキュメント https://code.claude.com/docs/ja/memory を指す。

## ロケーションと優先度

| スコープ | 場所 | 適用範囲 |
|---|---|---|
| User | `~/.claude/rules/` | すべてのプロジェクト |
| Project | `<project>/.claude/rules/` | そのプロジェクトのみ |

公式仕様: ユーザーレベルの rules がプロジェクトレベルより前にロードされ、プロジェクトレベルが優先 (memory.md「ユーザーレベルのルール」セクション)。

`InstructionsLoaded` hook の `memory_type` には `User`/`Project`/`Local`/`Managed` の 4 値が存在する。`Managed` は管理ポリシーレベルの rules を指すと推測されるが、本ドキュメントでは未検証。

## ロードタイミング

frontmatter の `paths` の有無で挙動が変わる。

### `paths` なしの rule (= 常時ロード)

- 起動時 (`load_reason: "session_start"`) に CLAUDE.md と同格でロードされる
- セッション中は常にコンテキストに乗る
- 公式: 「`paths` frontmatter のないルールは、`.claude/CLAUDE.md` と同じ優先度で起動時に読み込まれます」(memory.md)

### `paths` 付きの rule (= 条件付きロード)

- 起動時にはロードされない
- パターンに合致するファイルが Read されたとき (`load_reason: "path_glob_match"`) にロードされる
- 一度ロードされた rule は同セッション中に再ロードされない (キャッシュ的挙動、実機 v2.1.119 で確認)
- グローバル (`memory_type: "User"`) とプロジェクト (`memory_type: "Project"`) の両方が独立に評価される。同じ Read で両方のレベルの paths rule が同時にトリガーされる (実機 v2.1.119 で確認)
- 公式: 「パススコープルールは、すべてのツール使用時ではなく、パターンに一致するファイルを読むときにトリガーされます」(memory.md)

## paths の評価タイミング (重要)

`paths` の評価は **Read ツールの実行時** にのみ行われる (実機 v2.1.119 で確認)。これは公式の「ファイルを読むときにトリガーされます」(memory.md) と一致し、以下の挙動を導く。

| 操作 | paths 付き rule の発火 |
|---|---|
| `Read` 既存ファイル | ✅ 発火 |
| `Read` → `Edit` (Read 済み) | Read 時のみ発火、Edit では再評価なし |
| `Read` → `Write` (Read 済み既存ファイル) | Read 時のみ発火、Write では再評価なし |
| `Write` 単体 (新規ファイル作成、Read 未経由) | ❌ **発火しない** |

### Write 単体の盲点とワークアラウンド

新規ファイルを `Write` だけで作ると `paths` rule は適用されない。回避策は 3 ステップ:

1. `Bash` で `touch <path>` (空ファイル作成)
2. `Read` で空ファイルを読む (paths が発火、rule がロード)
3. `Write` で実際の内容を書き込む

実機検証 (v2.1.119) で、空ファイル (0 バイト) でも `Read` で `path_glob_match` が発火することを確認済み。CLAUDE.md でこの 3 ステッププロトコルを指示しておけば、エージェントが自律的に実行する。条件として `Bash(touch *)` を allow しておく必要がある。

## frontmatter キー

`paths` のみが公式 memory.md に明記されている。

```yaml
---
paths:
  - "**/*.ts"
  - "src/**/*"
---
```

### glob パターン

memory.md より:

| パターン | 一致 |
|---|---|
| `**/*.ts` | 任意のディレクトリ内のすべての TypeScript ファイル |
| `src/**/*` | `src/` 以下のすべてのファイル |
| `*.md` | プロジェクトルート直下のマークダウンファイル |
| `src/components/*.tsx` | 特定ディレクトリ内の React コンポーネント |

ブレース展開 `{ts,tsx}` および複数パターン指定可能。

### description フィールド

`description` を書いても `InstructionsLoaded` hook の入力には現れない (実機 v2.1.119 で確認)。スキルの `description` (auto-invoke trigger) と同じ仕組みかは確認できていない。Claude 内部で何らかの用途に使われているかは公式に記載がなく、観測手段もない。

## InstructionsLoaded hook での観測

`InstructionsLoaded` hook の入力スキーマ:

```json
{
  "session_id": "...",
  "transcript_path": "...",
  "cwd": "...",
  "hook_event_name": "InstructionsLoaded",
  "file_path": "<absolute path of loaded rule>",
  "memory_type": "User|Project|Local|Managed",
  "load_reason": "session_start|nested_traversal|path_glob_match|include|compact",
  "globs": ["..."],
  "trigger_file_path": "..."
}
```

`globs` は `path_glob_match` 時のみ。`trigger_file_path` は遅延ロード時のみ。matcher は `load_reason` をフィルタする。出力に `decision` 制御はなく監査用のみ。

## デバッグ手段

- **`/memory` コマンド**: ロード済み CLAUDE.md / CLAUDE.local.md / rules を一覧表示
- **`InstructionsLoaded` hook**: ファイルレベルのロード履歴をログに残せる

想定している rule が実際にロードされているかを実測する手段。

## hook との使い分け

`paths` rule と `PostToolUse:Edit|Write` hook は似て非なる仕組み。

- `paths` rule: 該当ファイルを **Read 開始時** にスタンディング指示として注入
- `PostToolUse` hook: ツール実行 **直後** に追加コンテキストを注入

`Write` 単体 (新規ファイル作成) の盲点を埋めるには `paths` rule では不十分で、hook が必要。逆に「ファイルを読み始めたタイミングで規範を注入したい」場合は rule の方が自然。

## サブディレクトリ

`.claude/rules/` 内のサブディレクトリ (例: `frontend/`、`backend/`) も再帰的に発見される (公式 memory.md)。シンボリックリンクもサポート、循環は検出される。

## 参考

- 公式: https://code.claude.com/docs/ja/memory#path-specific-rules
- 公式: https://code.claude.com/docs/ja/hooks (`InstructionsLoaded` hook)
- 抽出物: `~/.local/share/claude-code-system-prompts/system-prompts/skill-init-claudemd-and-skill-setup-new-version.md`
