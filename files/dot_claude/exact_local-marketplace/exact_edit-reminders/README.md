# Edit Reminders

ターンの終わりに「ドキュメントの整合性確認」と「エージェント向けドキュメントのメンテ確認」のリマインダーを注入する hook 群。エージェントが編集・削除のあとにドキュメント側の更新を取りこぼすことを防ぐ。

## What It Does

ターン中の変更を CWD の git 作業ツリーのスナップショット差分で観察し、Stop 時に該当するリマインダーを `decision: "block"` の `reason` として注入する。

| 検知対象 | 出るリマインダー |
|---|---|
| `.md` ファイルの変更 | `[doc-consistency]` — 内部矛盾・用語の揺れ・見出し階層・相互参照の整合性などのチェックリスト |
| 非 `.md` ファイルの変更 | `[doc-followup]` — CLAUDE.md / .claude/rules/ / docs/ などエージェント向けドキュメントが古くなっていないかの確認 |
| ファイル削除 (tracked の `D`/`R`、または untracked からの消失) | `[doc-followup]` に「削除済みファイルへの参照・リンクが残っていないか」の補足を追記 |

両条件に該当するときは `[doc-consistency]` と `[doc-followup]` の両方を 1 つの reason に並べて注入する。`block` は 1 ターンに 1 回だけ (詳細は後述)。

リマインダーは強制ではない。「不要と判断したならその旨だけ表明して進めばよい」が末尾に付く。

## How It Works

### 3 つの hook の役割

| Hook | Event | 動作 |
|---|---|---|
| `session-start-gc.sh` | `SessionStart` | state root 配下の `<session_id>/` を sweep し、7 日以上更新されていない dir を削除 (終了済みセッションの掃除) |
| `reset-turn-state.sh` | `UserPromptSubmit` | 自セッションの state dir をクリア、直後に `git stash create` で tracked のスナップショット (`snap-tracked`)、`ls-files --others --exclude-standard` × `git hash-object` で untracked の `<hash>\t<path>` 一覧 (`snap-untracked`) を保存 |
| `edit-reminders-on-stop.sh` | `Stop` | スナップショットと現状の差分から `has_md` / `has_impl` / `has_deleted` を判定、reason を組み立て `decision: "block"` で注入。`blocked` フラグを立てて二重発火を防ぐ |

互いに状態 (`${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/<session_id>/`) を介して協調する 1 セット。

### 状態ディレクトリのレイアウト

```
${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/<session_id>/
├── snap-tracked    # ターン開始時の git stash create commit-ish (空なら HEAD)
├── snap-untracked  # ターン開始時の untracked の <hash>\t<path> 一覧 (path で sort 済み)
└── blocked         # Stop で reason 注入済みのフラグ (空ファイル)
```

### ターンのライフサイクル

```
SessionStart (セッション開始時 1 回)
  └─ session-start-gc.sh
       └─ state root から 7 日以上更新が無い session dir を削除

UserPromptSubmit
  └─ reset-turn-state.sh
       ├─ 状態ディレクトリを rm -rf
       ├─ git stash create で snap-tracked を保存 (dirty でなければ HEAD)
       └─ ls-files --others --exclude-standard と git hash-object で
          snap-untracked (<hash>\t<path> 一覧) を保存

Stop
  └─ edit-reminders-on-stop.sh
       ├─ blocked が既にあれば exit 0 (二重発火防止)
       ├─ 現状の stash create と snap-tracked を git diff --name-status -M で比較
       ├─ 現状の untracked <hash>\t<path> 一覧と snap-untracked を path key で
          マージし ADDED / MODIFIED / REMOVED に分類
       ├─ パスの拡張子と status code から has_md / has_impl / has_deleted を判定
       ├─ 該当する reason を組んで decision:"block" で注入
       └─ blocked フラグを立てる
```

### なぜ Stop で `decision: "block"` を使うのか

Stop イベントでは `hookSpecificOutput.additionalContext` が無効で、エージェントにメッセージを届ける手段は `decision: "block"` + `reason` のみ (Claude Code の hook 仕様)。

`block` は本来「停止のブロック=強制継続」のため、毎ターン奪うと煩い。そこで `blocked` フラグで「ターン内で既に注入済み」を記録し、同一ターンの 2 回目以降の Stop では発火しない。フラグの削除は次のユーザー入力ターン開始時 (`UserPromptSubmit`) に `reset-turn-state.sh` が行う。

### なぜ tracked と untracked を別々にスナップショットするのか

`git stash create` は tracked content (work tree + index) のみを commit-ish として封じる。untracked は対象外なので、`ls-files --others --exclude-standard` のパス一覧 + 各 path の `git hash-object` を別途保存する。

このペアで以下が一度に拾える:

- 既に dirty なファイルへの追記 (= stash content が変わるので `git diff` に出る)
- 新規ファイル作成 (= untracked 一覧に追加される)
- 既存 untracked ファイルへの追記 (= path は同じだが `hash-object` の hash が変わる)
- ファイル削除 (= tracked なら `D`、untracked なら一覧から消える)
- リネーム (= `git diff -M` の `R` で旧パス・新パスとも検知)
- `git add` 由来の untracked 一覧からの消失は tracked 側の `A` と突き合わせて削除誤判定を回避

`git status` / `stash create` は `--no-optional-locks` 付きで実行する (`.git/index.lock` の残置回避、cf. `files/dot_local/share/zsh/exact_functions/exact_Prompts/prompt_zen_setup`)。

## Detection Scope

### 検知する

CWD の git 作業ツリーで発生した、`.gitignore` 配下を除く全ての変更を、変更経路によらず一律に拾う:

- `Edit` / `Write` / `NotebookEdit` tool による編集
- サブエージェント (`Agent` tool) 内の編集
- MCP server 経由の編集
- `Bash` tool 経由のあらゆるファイル操作 (`rm`, `mv`, `cp`, `sed -i`, リダイレクト等)
- リネーム (`git mv` でも普通の `mv` でも、`git diff -M` で `R` として検知)

### 検知しない

- CWD の git 作業ツリー外の変更 (e.g. `~/.local/state/...` への書き込み、別リポジトリへの編集)
- `.gitignore` で除外されたパス (e.g. `.agents/` などの作業メモ)
- git リポジトリでない CWD (snapshot を取る対象が無いため、Stop でも何もしない)

設計判断: ノイズ (CWD 外への書き込み、`.agents/` への作業メモ等) を構造的に除外したいので、検知の根拠を CWD の git 作業ツリーに統一した。経路 (Edit/Write/Bash/Agent/MCP) によらずファイルシステム状態のみで判定するため、検知漏れも誤検知も少ない。

## Configuration

このプラグインを有効化するには、Claude Code の `settings.json` に以下を登録する:

```json
{
  "extraKnownMarketplaces": {
    "local": {
      "source": {
        "source": "directory",
        "path": "/path/to/local-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "edit-reminders@local": true
  }
}
```

`hooks.json` 内のスクリプト参照は `${CLAUDE_PLUGIN_ROOT}` (Claude Code がプラグインのルートに解決する組み込み変数) を使うので、配置パスに依存しない。

このリポジトリでは `files/dot_claude/settings.json.tmpl` で chezmoi の `{{ .chezmoi.homeDir }}` を埋めて `path` をマシン横断で解決している。
