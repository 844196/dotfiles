---
paths:
  - "**/.claude/rules/*.md"
  - "**/.claude/skills/**/SKILL.md"
  - "**/CLAUDE.md"
---

# Claude Code 自身のメタ情報

CLAUDE.md / rules / skills を保守・新規作成するとき、Claude Code 固有の挙動 (paths のトリガー、評価タイミング、優先度、frontmatter キー、スキルの特殊構文、ライフサイクル等) を判断する場合は以下を必ず参照する。エージェントが標準知識として持っていない情報のため。

- rules ディレクトリの仕組み: `~/.claude/docs/claude-code-rules.md`
- スキルの仕組み: `~/.claude/docs/skills.md`
