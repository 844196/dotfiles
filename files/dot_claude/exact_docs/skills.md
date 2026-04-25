# スキル

`SKILL.md` ファイルで Claude Code を拡張する公式機能。本文は使用時にのみ読み込まれる (CLAUDE.md と異なり常時ロードされない)。

以下、「公式 skills.md」は https://code.claude.com/docs/ja/skills を指す。

## 場所と優先度

| スコープ | 場所 | 適用範囲 |
|---|---|---|
| Enterprise | 管理設定参照 | 組織内のすべてのユーザー |
| Personal | `~/.claude/skills/<name>/SKILL.md` | すべてのプロジェクト |
| Project | `<project>/.claude/skills/<name>/SKILL.md` | このプロジェクトのみ |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | プラグインが有効な場所 |

優先度: Enterprise > Personal > Project。プラグインスキルは `plugin-name:skill-name` 名前空間で競合を回避する。

ネスト: サブディレクトリ内のファイル操作時、`<subdir>/.claude/skills/` も自動検出される (モノレポ対応)。

## frontmatter キー

公式 skills.md より:

| キー | 説明 |
|---|---|
| `name` | スキル名 (省略時はディレクトリ名)。`/<name>` と一致 |
| `description` | 推奨。Claude が auto-invoke するか判断する材料。`when_to_use` と合わせて 1,536 文字に短縮されうる |
| `when_to_use` | auto-invoke の追加コンテキスト (トリガーフレーズなど) |
| `argument-hint` | オートコンプリート時のヒント (例 `[issue-number]`) |
| `arguments` | `$name` 置換用の名前付き位置引数 |
| `disable-model-invocation` | `true` で Claude による自動呼び出しを禁止 |
| `user-invocable` | `false` で `/` メニューから非表示 |
| `allowed-tools` | スキルアクティブ中、リスト内のツールを許可なしで使用可能 |
| `model` | このスキル中だけ使用するモデル |
| `effort` | 努力レベル (`low`/`medium`/`high`/`xhigh`/`max`) |
| `context` | `fork` でサブエージェントコンテキストで実行 |
| `agent` | `context: fork` で使うサブエージェントタイプ |
| `hooks` | このスキルのライフサイクルにスコープされたフック |
| `paths` | アクティブ化を制限する Glob パターン (memory.md と同じ構文) |
| `shell` | `` !`...` `` ブロックのシェル (`bash`/`powershell`) |

## 文字列置換

公式 skills.md より:

| 変数 | 説明 |
|---|---|
| `$ARGUMENTS` | スキル呼び出し時の全引数 |
| `$ARGUMENTS[N]` | 0-indexed の特定引数 |
| `$N` | `$ARGUMENTS[N]` の短縮 (例 `$0`) |
| `$name` | `arguments` フロントマターで宣言した名前付き引数 |
| `${CLAUDE_SESSION_ID}` | 現在のセッション ID |
| `${CLAUDE_SKILL_DIR}` | このスキルの SKILL.md があるディレクトリ |

`$ARGUMENTS` がスキル本文に存在しない場合、`ARGUMENTS: <value>` として末尾に追加される。

これらは **環境変数ではなくレンダリング前の文字列置換**。スキル呼び出し時に SKILL.md の本文中の placeholder が置換され、その結果が単一メッセージとして注入される。適用範囲は SKILL.md ファイル内 (frontmatter ではなく本文) に限られる。エージェント側で `env` などで取得する必要はない (取得しても存在しない)。

## プリプロセッシング: `` !`...` `` と ` ```! ` ブロック

スキルコンテンツが Claude に送られる前にシェル実行され、出力で置換される。Claude は最終結果のみを見る (= 前処理であり、Claude が実行するものではない)。

インライン:

```md
PR diff: !`gh pr diff`
```

複数行は ` ```! ` フェンスコードブロック:

````md
```!
node --version
git status --short
```
````

### 落とし穴

- **キャッシュなし**: スキルが呼び出されるたびに毎回実行される
- **並列実行**: 複数コマンドは並列で動く。順序依存があるなら 1 つのブロックにまとめる
- **指示文中での使用は危険**: 指示文中に `` !`...` `` を書くと、指示文自体が出力で置換され読めない指示になる場合がある。動的な指示文はスクリプト側でレンダリングする
- **パーミッション**: `` !`...` `` のコマンドは `settings.json` の `permissions.allow` の影響を受ける
- **`allowed-tools` で Bash パターンは効かない** ([#14956](https://github.com/anthropics/claude-code/issues/14956))。スキルの `allowed-tools: Bash(git:*)` のようにしても本文の `` !`...` `` には適用されない。`settings.json` の `permissions.allow` に追加する必要がある
- **無効化**: `settings.json` の `disableSkillShellExecution: true` で各コマンドが `[shell command execution disabled by policy]` に置換される (バンドル/管理スキルは影響を受けない)

## HTML コメントの扱い

SKILL.md 内の `<!-- ... -->` は **削除されずそのまま Claude に届く** (実機 v2.1.119 で検証)。コードブロック内・外、ブロックレベル・インラインを問わず保持される。プリプロセッシングで行われるのは文字列置換と `` !`...` `` 実行のみで、コメント除去は含まれない。

CLAUDE.md とは挙動が異なる: CLAUDE.md ではブロックレベル HTML コメントは Claude のコンテキストに注入される前に削除され、コードブロック内のみ保持される (公式 memory.md「CLAUDE.md ファイルの読み込み方法」)。

含意:

- SKILL.md にコメントを書くとトークンを消費する
- エージェント向けの注意書きをコメント形式で残しても機能する (= 人間とエージェント両方が見る)
- 人間専用のメモを残したい場合はトークン消費を許容するか、別ファイルに分離する

## ライフサイクル

スキルが呼び出されると、レンダリング済みの `SKILL.md` が単一メッセージとしてセッションに注入される。後のターンで再ロードされない。

→ スタンディング指示として書く (= 1 回限りのステップではなく、タスク全体を通じて適用すべきガイダンス)。

自動コンパクション後は最新呼び出しの最初の 5,000 トークンを再アタッチ。再アタッチされたスキル群は合計 25,000 トークン予算を共有し、最近呼び出されたスキルから順に埋められる (古いスキルはコンパクション後に完全にドロップされうる)。

## 呼び出し制御

| 設定 | ユーザー呼出 | Claude 呼出 | コンテキスト読み込み |
|---|---|---|---|
| デフォルト | ✅ | ✅ | description は常時、本体は呼び出し時 |
| `disable-model-invocation: true` | ✅ | ❌ | description は読み込まれない、本体はユーザー呼出時 |
| `user-invocable: false` | ❌ | ✅ | description は常時、本体は Claude 呼出時 |

## カスタムコマンドとの統合

`.claude/commands/<name>.md` (旧形式) と `.claude/skills/<name>/SKILL.md` (新形式) は両方とも `/<name>` を作る。同名はスキルが優先。新形式はサポートファイル・呼出制御・自動ロードなどの追加機能あり。

## `--add-dir` の例外

`--add-dir` で渡したディレクトリはファイルアクセス権を与えるが、設定はデフォルトでは読まれない。スキルだけは例外で、`<add-dir>/.claude/skills/` は自動的に読み込まれる。CLAUDE.md・rules・agents・commands は読まれない (CLAUDE.md は `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` で有効化可)。

## ライブ変更検出

`~/.claude/skills/`、`<project>/.claude/skills/`、`--add-dir` 内の `.claude/skills/` 配下のスキルファイル変更は、再起動なしに現在のセッションで反映される。新規の最上位スキルディレクトリは再起動が必要。

## 参考

- 公式: https://code.claude.com/docs/ja/skills
- 関連 issue: https://github.com/anthropics/claude-code/issues/14956 (allowed-tools の Bash パターン制限)
- 抽出物: `~/.local/share/claude-code-system-prompts/system-prompts/skill-init-claudemd-and-skill-setup-new-version.md`
