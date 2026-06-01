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
