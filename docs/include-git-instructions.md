# `includeGitInstructions: false` の影響

`files/dot_claude/settings.json` で `includeGitInstructions: false` を設定している。このフラグが false の場合、Claude Code のシステムプロンプトから commit / PR 作成のデフォルト指令一式が外れる。本リポジトリでは独自の commit / PR スキル群を運用しており、その分の補償を複数のファイルで分担している。

## なぜ false にしているか

- 本リポジトリは独自の `commit` / `commit-amend` / `pr` / `headless-commit` / `headless-commit-amend` スキルを運用しており、Claude Code のデフォルト手順と二重化させたくない
- とくに `pr` スキルは `gh pr create --web` でブラウザを開くだけのワークフロー (PR 自体はユーザーがブラウザで作成) を採用しているため、「`gh pr create` で直接 PR を作る」というデフォルト指令と矛盾する
- attribution (Co-Authored-By トレーラー) はモデル名展開を含む独自仕様のため、組み込みの `${COMMIT_CO_AUTHORED_BY_CLAUDE_CODE}` 展開ではなく自前で挿入している

## false で読み込まれなくなる指令

`~/.local/share/claude-code-system-prompts/system-prompts/tool-description-bash-git-commit-and-pr-creation-instructions.md` 全体 (約 96 行) が読み込まれなくなる。主な内容:

- Git Safety Protocol (`NEVER update the git config`、破壊的コマンド禁止、`--no-verify` 禁止、main への force push 警告、新規コミット優先、`git add -A` / `.` 抑制、明示指示なきコミット禁止)
- コミット手順 (`git status` / `git diff` / `git log` の並列実行 → 分析 → メッセージ起草 → ステージ + commit + status の並列実行 → 失敗時は新規コミット)
- HEREDOC 形式でのコミットメッセージ受け渡し
- `${COMMIT_CO_AUTHORED_BY_CLAUDE_CODE}` トレーラーの挿入
- PR 作成手順 (`git status` / `git diff` / `git log` 並列実行 → 分析 → ブランチ作成 / push / `gh pr create`)
- `${PR_GENERATED_WITH_CLAUDE_CODE}` トレーラーの挿入

## どこで何を補償しているか

| 補償対象 | 補償方法 |
|---|---|
| commit のフロー (status/diff/log → message → commit) | `files/dot_claude/skills/exact_commit/SKILL.md.tmpl` + `files/.chezmoitemplates/commit-skill-steps.md` |
| amend のフロー | `files/dot_claude/skills/exact_commit-amend/SKILL.md.tmpl` + `files/.chezmoitemplates/commit-amend-skill-body.md` |
| Co-Authored-By トレーラー (モデル名展開込み) | `files/dot_claude/settings.json` の `attribution.commit` + `files/exact_dot_844196/exact_bin/executable_git-claude-attribution` (commit スキルから `!\`git claude-attribution\`` で読み出し) |
| PR 作成フロー (ブラウザ経由) | `files/dot_claude/skills/exact_pr/SKILL.md.tmpl` + `files/.chezmoitemplates/creating-pull-requests-body.md` |
| ヘッドレスコミット (haiku モデルでの `--print` 実行) | `files/dot_claude/skills/exact_headless-commit{,-amend}/SKILL.md.tmpl` + `files/exact_dot_844196/exact_bin/executable_git-claude-commit` |
| Git Safety Protocol (破壊的コマンド禁止等) | 明示的には補償していない (Claude のデフォルト挙動に委ねる) |

## 関連ファイル

`includeGitInstructions: false` を切り替える、または commit / PR まわりの設計を変えるときに連動を考えるべきファイル:

- `files/dot_claude/settings.json`
- `files/dot_claude/skills/exact_commit/SKILL.md.tmpl`
- `files/dot_claude/skills/exact_commit-amend/SKILL.md.tmpl`
- `files/dot_claude/skills/exact_headless-commit/SKILL.md.tmpl`
- `files/dot_claude/skills/exact_headless-commit-amend/SKILL.md.tmpl`
- `files/dot_claude/skills/exact_pr/SKILL.md.tmpl`
- `files/.chezmoitemplates/commit-skill-steps.md`
- `files/.chezmoitemplates/commit-amend-skill-body.md`
- `files/.chezmoitemplates/creating-pull-requests-body.md`
- `files/exact_dot_844196/exact_bin/executable_git-claude-commit`
- `files/exact_dot_844196/exact_bin/executable_git-claude-attribution`

漏れがあれば次のコマンドで拾う:

```bash
git grep -lE 'commit|pull[ -]?request|attribution|Co-Authored-By' files/
git grep -l 'includeGitInstructions' files/
```

## 参考

- 元の指令の実体: `~/.local/share/claude-code-system-prompts/system-prompts/tool-description-bash-git-commit-and-pr-creation-instructions.md`
- システムプロンプト集の概要: `~/.claude/docs/system-prompts.md`
