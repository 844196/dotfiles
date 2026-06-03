# Claude Code セッションの調査: session-analyzer と atuin の使い分け

Claude Code セッションを調査するためのエージェントが 2 つある。どちらも突き合わせの軸は Claude Code セッション ID になる。本ルールは「両方を使う側」の視点で、両者の守備範囲とチェーンのつなぎ方をまとめる。

## 守備範囲

何を手がかりに渡すかで返るものが変わる。特に `atuin:command-history-analyzer` は「コマンド断片」と「Claude Code セッション ID」のどちらでも引けて、向きによって返るものが逆になる。

| 呼び出し | データソース | 返るもの |
|---|---|---|
| `session-analyzer:session-analyzer` に Claude Code セッション ID を渡す | `~/.claude/projects/*/<session-id>.jsonl` | そのセッションの会話内容の要約・回答 (意図・経緯・思考過程)。Bash の正確な引数・終了コードまでは埋められない |
| `atuin:command-history-analyzer` にコマンド断片を渡す | atuin DB | そのコマンドを実行した Claude Code セッション ID (複数あり得る) |
| `atuin:command-history-analyzer` に Claude Code セッション ID を渡す | atuin DB | そのセッションで実行された Bash ツールコマンドの完全な実行履歴 (引数・終了コード・時刻・cwd) |

## チェーンのつなぎ方

### 手がかりがコマンド断片のとき (Claude Code セッション ID を知りたい)

1. `atuin:command-history-analyzer` にコマンド断片を渡し、それを実行した Claude Code セッション ID を逆引きする
2. 得られた Claude Code セッション ID を `session-analyzer:session-analyzer` に渡し、当時の会話文脈 (意図・経緯) を読ませる

### 手がかりが Claude Code セッション ID のとき (そのセッションの実コマンドを知りたい)

1. `atuin:command-history-analyzer` に Claude Code セッション ID を渡し、そのセッションで実行された Bash コマンド列 (引数・終了コード・時刻・cwd) を時系列で取り出す
   - transcript では省略・要約されがちな引数や終了コードを atuin 側が埋める。逆引きではなく「順引き」のケース
2. 会話文脈 (なぜそれをやったか) も併せて欲しいなら、同じ Claude Code セッション ID を `session-analyzer:session-analyzer` にも投げて突き合わせる。

1 および 2 は並行に投げるとよい。
