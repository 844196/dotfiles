# Claude Code セッションの調査: ctx と atuin の使い分け

Claude Code セッションを調査するためのツールが 2 つある。どちらも突き合わせの軸は Claude Code セッション ID になる。本ルールは「両方を使う側」の視点で、両者の守備範囲とチェーンのつなぎ方をまとめる。

## 守備範囲

何を手がかりに渡すかで返るものが変わる。特に `atuin:command-history-analyzer` は「コマンド断片」と「Claude Code セッション ID」のどちらでも引けて、向きによって返るものが逆になる。

| 呼び出し | データソース | 返るもの |
|---|---|---|
| `ctx-agent-history-search` スキル (`ctx search` / `ctx show session <id>` 等) に Claude Code セッション ID を渡す | ctx が取り込んだトランスクリプト (`~/.claude/projects/*/<session-id>.jsonl` 等) | そのセッションの会話内容の要約・回答 (意図・経緯・思考過程)。Bash の正確な引数・終了コードまでは埋められない |
| `atuin:command-history-analyzer` にコマンド断片を渡す | atuin DB | そのコマンドを実行した Claude Code セッション ID (複数あり得る) |
| `atuin:command-history-analyzer` に Claude Code セッション ID を渡す | atuin DB | そのセッションで実行された Bash ツールコマンドの完全な実行履歴 (引数・終了コード・時刻・cwd) |

## チェーンのつなぎ方

### 手がかりがコマンド断片のとき (Claude Code セッション ID を知りたい)

1. `atuin:command-history-analyzer` にコマンド断片を渡し、それを実行した Claude Code セッション ID を逆引きする
2. 得られた Claude Code セッション ID を `ctx-agent-history-search` スキル経由で `ctx search --session <id>` などに渡し、当時の会話文脈 (意図・経緯) を読ませる

### 手がかりが Claude Code セッション ID のとき (そのセッションの実コマンドを知りたい)

1. `atuin:command-history-analyzer` に Claude Code セッション ID を渡し、そのセッションで実行された Bash コマンド列 (引数・終了コード・時刻・cwd) を時系列で取り出す
   - transcript では省略・要約されがちな引数や終了コードを atuin 側が埋める。逆引きではなく「順引き」のケース
2. 会話文脈 (なぜそれをやったか) も併せて欲しいなら、同じ Claude Code セッション ID を `ctx-agent-history-search` スキル経由でも引いて突き合わせる

atuin はサブエージェント、ctx はメインエージェントでのスキル実行なので "並列 spawn" にはならないが、メインが ctx を叩きながら atuin をサブエージェントとして立てて同時に進めるとよい。
