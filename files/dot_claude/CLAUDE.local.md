# `files/dot_claude/` (`~/.claude/`)

特筆すべきファイルとディレクトリ:
- `literal_CLAUDE.md` — `literal_` で chezmoi に prefix 解釈をスキップさせ、ターゲットでは `~/.claude/CLAUDE.md` として配置される。
- `exact_local-marketplace/` — ローカル専用プラグインのマーケットプレイス。協調する複数 hook を 1 セットでバンドルしたい場合は単独 hook (`exact_hooks/`) ではなくこちらに切り出す。

## ~/.claude/CLAUDE.md vs ~/.claude/rules/ の棲み分け

`literal_CLAUDE.md` は肥大化させず横断メタだけに絞る。

- 横断メタ原則 (rule/skill 全体に効く、paths 付き rule の発火条件を前提にした指令など) → `literal_CLAUDE.md`
- 独立トピック (バグ修正、mise タスクなど、ファイル単位で分割したい規範・知識) → paths なし `exact_rules/*.md`
