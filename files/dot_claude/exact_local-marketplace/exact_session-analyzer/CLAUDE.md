# Session Analyzer

過去の Claude Code セッションのトランスクリプト (JSONL) を読み取り専用で解析するエージェントを提供するプラグイン。

## 構成要素

| 要素 | 役割 |
|---|---|
| [`session-analyzer` エージェント](exact_agents/session-analyzer.md) | セッション ID と質問を渡すと、対象セッションの JSONL を Grep / Read / jq で掘って答える読み取り専用エージェント |
| [`exact_bin/executable_transcript-path`](exact_bin/executable_transcript-path) | セッション ID から JSONL パス (`~/.claude/projects/<slug>/<id>.jsonl`) を解決する裸コマンド。エージェントが手順 1 で使う |
| [SessionStart フック](exact_hooks/hooks.json) と [`exact_rules/session-start.md`](exact_rules/session-start.md) | SessionStart で proactive 発動条件 (ハンドオーバーから始まったセッション、ユーザーが過去セッションを参照したとき) を告知 |

## 役割の境界

- 読み取り対象は `~/.claude/projects/*/<session-id>.jsonl` のみ
- 状態を変更する操作 (Edit/Write/外部送信) は行わない読み取り専用エージェント

似た役割の他プラグインとの分担:

| エージェント | データソース | 担当する情報 |
|---|---|---|
| `session-analyzer:session-analyzer` (このプラグイン) | `~/.claude/projects/*/<session-id>.jsonl` | 会話 transcript (なぜそれをやったか) |
| [`atuin:command-history-analyzer`](../exact_atuin/exact_agents/command-history-analyzer.md) | atuin DB | Bash 実コマンド列 (実際に何を打ったか・引数・終了コード・時刻) |

両者は同じ session ID で突き合わせられる。コマンド断片しか手がかりが無いときは atuin で session ID を逆引きしてからこのエージェントに渡すのが自然 ([atuin の recall-commands スキル](../exact_atuin/exact_skills/exact_recall-commands/SKILL.md) ユースケース 2 を参照)。

## 他プラグインからの参照

- [atuin](../exact_atuin/CLAUDE.md): `recall-commands` スキルの連携相手として `dependencies` に宣言
