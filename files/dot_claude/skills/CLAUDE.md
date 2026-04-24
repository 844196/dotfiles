# skills

## スキルのプリプロセッシング構文

スキルが呼び出されるたびに毎回処理される（キャッシュされない）。Claude が見るのは置換後の結果のみ。

### シェルコマンド: `` !`...` ``

```markdown
現在のブランチ: !`git branch --show-current`
# → Claude には "現在のブランチ: main" と見える
```

複数行の場合は ` ```! ` ブロックを使う。複数コマンドは並列実行されるので、順序依存があるなら1つのブロックにまとめる：

````markdown
```!
git log --oneline -5
```
````

**注意**: 指示文の中で使うと、指示文自体が置換されて意味不明になる。動的な指示文が必要な場合は、スクリプト側で指示文ごとレンダリングする。

### パーミッション

`` !`...` `` のコマンドは settings.json の permissions の影響を受ける。スキルの `allowed-tools` フロントマターでは Bash パターンは効かない（[#14956](https://github.com/anthropics/claude-code/issues/14956)）。必要に応じて settings.json の `permissions.allow` に追加する。

### 変数: `${CLAUDE_SESSION_ID}`

スキル本文に書くと、呼び出し時に実際の UUID に置換される：

```markdown
出力先: .agents/sessions/${CLAUDE_SESSION_ID}_review.md
```

これは環境変数ではなく、Claude Code の TypeScript ランタイムによる文字列置換。スキル本文でのみ機能し、Hook やシェルコマンド内では使えない。

REF: https://code.claude.com/docs/en/skills#advanced-patterns

## commit / commit-amend / headless-commit / headless-commit-amend

SEE ALSO: `../../exact_dot_844196/exact_bin/executable_git-claude-commit`

## fork-tmux / handover-tmux

SEE ALSO: `../../exact_dot_844196/exact_bin/executable_claude-yolo`
