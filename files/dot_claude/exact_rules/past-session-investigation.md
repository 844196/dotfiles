# 過去セッションの調査 — atuin と session-analyzer の使い分け

過去 (または現在) の Claude Code セッションを調査するための読み取り専用エージェントが 2 つある。どちらも突き合わせの軸は **session ID**。本ルールは「両方を使う側」の視点で、両者の守備範囲とチェーンのつなぎ方をまとめる。

atuin プラグインと session-analyzer プラグインの両方が有効なときに効く。片方しか入っていなければ、入っている側だけを使う。

## 守備範囲

| エージェント | データソース | 答えられること |
|---|---|---|
| [`atuin:command-history-analyzer`](../exact_local-marketplace/exact_atuin/exact_agents/command-history-analyzer.md) | atuin DB | Bash 実コマンド列 — 実際に何を打ったか、引数・終了コード・時刻・cwd |
| [`session-analyzer:session-analyzer`](../exact_local-marketplace/exact_session-analyzer/exact_agents/session-analyzer.md) | `~/.claude/projects/*/<session-id>.jsonl` | 会話 transcript — なぜそれをやったか、どんな思考を経たか |

ざっくり言えば、atuin 側が「いつ・どの session で・どんなコマンドを」、session-analyzer 側が「なぜそれをやったのか」を埋める。

## チェーンのつなぎ方

手がかりがコマンド断片しか無いときは、次の順でつなぐと自然:

1. `atuin:command-history-analyzer` にコマンド断片を渡し、それを実行した session ID を逆引きする
2. 得られた session ID を `session-analyzer:session-analyzer` に渡し、当時の会話文脈 (意図・経緯) を読ませる

逆に session ID が先に分かっているなら、両者を並行に投げて突き合わせてもよい。
