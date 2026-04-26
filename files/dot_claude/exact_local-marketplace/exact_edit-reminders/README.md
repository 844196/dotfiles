# Edit Reminders

ターンの終わりに「ドキュメントの整合性確認」と「エージェント向けドキュメントのメンテ確認」のリマインダーを注入する hook 群。エージェントが編集・削除のあとにドキュメント側の更新を取りこぼすことを防ぐ。

## What It Does

ターン中の編集を 4 つの hook で観察し、Stop 時に該当するリマインダーを `decision: "block"` の `reason` として注入する。

| 検知対象 | 出るリマインダー |
|---|---|
| `.md` ファイルの編集 | `[doc-consistency]` — 内部矛盾・用語の揺れ・見出し階層・相互参照の整合性などのチェックリスト |
| 非 `.md` ファイルの編集 | `[doc-followup]` — CLAUDE.md / .claude/rules/ / docs/ などエージェント向けドキュメントが古くなっていないかの確認 |
| ファイル削除 (Bash の `rm` / `git rm`、または git status での新規削除) | `[doc-followup]` に「削除済みファイルへの参照・リンクが残っていないか」の補足を追記 |

両条件に該当するときは `[doc-consistency]` と `[doc-followup]` の両方を 1 つの reason に並べて注入する。`block` は 1 ターンに 1 回だけ (詳細は後述)。

リマインダーは強制ではない。「不要と判断したならその旨だけ表明して進めばよい」が末尾に付く。

## How It Works

### 4 つの hook の役割

| Hook | Event | 動作 |
|---|---|---|
| `record-edit.sh` | `PostToolUse:Edit\|Write` | 編集ファイルの拡張子で振り分け、`md` または `impl` フラグを立てる |
| `record-deletion.sh` | `PostToolUse:Bash` | コマンド文字列を単語境界マッチで `rm` / `git rm` 検知、`deleted` フラグを立てる |
| `reset-turn-state.sh` | `UserPromptSubmit` | 状態ディレクトリを丸ごとクリア、直後に git status の削除一覧 (`git-snapshot`) を保存 |
| `edit-reminders-on-stop.sh` | `Stop` | フラグと git diff から reason を組み立て、`decision: "block"` で注入。`blocked` フラグを立てて二重発火を防ぐ |

互いに状態 (`${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/<session_id>/`) を介して協調する 1 セット。

### 状態ディレクトリのレイアウト

```
${XDG_STATE_HOME:-$HOME/.local/state}/claude/edit-reminders/<session_id>/
├── md            # .md 編集が発生したフラグ (空ファイル)
├── impl          # 非 .md 編集が発生したフラグ (空ファイル)
├── deleted       # rm / git rm を検知したフラグ (空ファイル)
├── git-snapshot  # ターン開始時点で git status が削除と認識していたパス一覧
└── blocked       # Stop で reason 注入済みのフラグ (空ファイル)
```

### ターンのライフサイクル

```
UserPromptSubmit
  └─ reset-turn-state.sh
       ├─ 状態ディレクトリを rm -rf
       └─ git-snapshot を作成 (現時点の削除パス一覧)

PostToolUse (ターン中、複数回)
  ├─ record-edit.sh      → md / impl フラグ
  └─ record-deletion.sh  → deleted フラグ

Stop
  └─ edit-reminders-on-stop.sh
       ├─ blocked が既にあれば exit 0 (二重発火防止)
       ├─ md / impl / deleted フラグを評価
       ├─ deleted が無ければ git-snapshot との diff で削除を補完検知
       ├─ 該当する reason を組んで decision:"block" で注入
       └─ blocked フラグを立てる
```

### なぜ Stop で `decision: "block"` を使うのか

Stop イベントでは `hookSpecificOutput.additionalContext` が無効で、エージェントにメッセージを届ける手段は `decision: "block"` + `reason` のみ (Claude Code の hook 仕様)。

`block` は本来「停止のブロック=強制継続」のため、毎ターン奪うと煩い。そこで `blocked` フラグで「ターン内で既に注入済み」を記録し、同一ターンの 2 回目以降の Stop では発火しない。フラグの削除は次のユーザー入力ターン開始時 (`UserPromptSubmit`) に `reset-turn-state.sh` が行う。

### 削除検知が二段構えな理由

`record-deletion.sh` は Bash の `rm` / `git rm` を単語境界マッチで拾うが、以下のケースでは漏れる:

- Bash 経由でも複雑なコマンド (パイプの奥、`xargs rm`、シェル関数経由など)
- そもそも Bash 以外の経路 (`git mv` でリネームされた旧パスなど)

これを補完するため、Stop hook 側で `UserPromptSubmit` 時点の `git-snapshot` と現在の `git status` を比較し、新規発生した削除を検知する。

`git status` は `--no-optional-locks` 付きで実行する (`.git/index.lock` の残置回避)。

## Detection Scope

### 検知する

- `Edit` / `Write` tool による編集
- `Bash` tool での `rm` / `git rm` (単語境界マッチ)
- ターン中に新規発生した git 上の削除 (rename の旧パスを含む)

### 検知しない

- `NotebookEdit` tool
- サブエージェント (`Agent` tool) 内での編集
- MCP server 経由の編集
- Bash の `mv` / `cp` / `touch` / `sed -i` / リダイレクト等 (削除以外のファイル操作)

設計判断: 削除はドキュメントの参照を破る影響が大きいため `PostToolUse:Bash` のパターンマッチを主、`git status` の snapshot diff を補完として二段で拾う。それ以外の操作 (mv/cp など) はリマインダー対象外。

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
