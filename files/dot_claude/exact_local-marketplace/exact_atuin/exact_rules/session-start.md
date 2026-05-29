[atuin] このセッションでは atuin プラグインが有効です。

Claude Code の Bash 実行は atuin 履歴に記録されており、`{session}` フィールドに Claude Code セッション ID が乗っている。これにより同一 / 他セッションの Bash 実コマンド列を機械的に引ける。

## エージェントの役割分担

session 関連の読み取り専用エージェントは 2 つあり、突き合わせ軸は session ID:

- `atuin:command-history-analyzer` (これ) — Bash 実コマンド列 (実際に何を打ったか、引数・終了コード・時刻) を atuin DB から取得
- `session-analyzer:session-analyzer` — 会話 transcript (なぜそれをやったか、どんな思考を経たか) を JSONL から取得

コマンド断片しか手がかりが無いとき、`atuin:command-history-analyzer` で session ID を逆引きしてから `session-analyzer:session-analyzer` に渡す、というチェーンが自然。

## 直接 Bash で叩く vs エージェント経由

atuin の生出力は数千〜数万行になり得る。メインで直接 Bash で `atuin` を叩くと、その出力がメインコンテキストに乗り続けて context window を圧迫する。

メインで直接叩いて構わない場面:
- 現セッションの直前数件を引く
- 終了コードを 1 件だけ確認する
- 1 回限りの軽量な確認

それ以外 (検索範囲が広い・複数クエリの組合せ・session-analyzer:session-analyzer 連携を含むチェーン・時間範囲俯瞰・複数 session の突き合わせ) は `atuin:command-history-analyzer` エージェントに委ねる。
エージェント側で生出力を閉じ込め、メインには整理されたサマリだけ返る。
