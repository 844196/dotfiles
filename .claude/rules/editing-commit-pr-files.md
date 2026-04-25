---
description: コミット・PR 周りのファイルを編集するときに参照する規範
paths:
  - files/dot_claude/settings.json
  - files/dot_claude/skills/exact_commit*/**
  - files/dot_claude/skills/exact_pr/**
  - files/dot_claude/skills/exact_headless-commit*/**
  - files/.chezmoitemplates/commit-*.md
  - files/.chezmoitemplates/creating-pull-requests-*.md
  - files/exact_dot_844196/exact_bin/executable_git-claude-*
---

# コミット・PR 周りのファイル編集

`files/dot_claude/settings.json` で `includeGitInstructions: false` にしているため、Claude Code のデフォルト commit/PR 指令はシステムプロンプトに読み込まれていない。代わりに本リポジトリ側で複数のファイルにわたって補償している。これらの周辺ファイル (commit / commit-amend / pr / headless-commit* スキル、`.chezmoitemplates/` の commit-* / creating-pull-requests-*、`git-claude-*` スクリプト、`settings.json` の `attribution` / `includeGitInstructions`) を編集する前に、何が消えていて何で補償しているかを `docs/include-git-instructions.md` で確認する。
