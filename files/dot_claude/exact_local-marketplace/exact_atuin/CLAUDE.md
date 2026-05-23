# Atuin

Claude Code の Bash 実行履歴を [atuin](https://atuin.sh/) に記録し、Claude Code セッション ID 単位で機械的にサルベージできるようにするプラグイン。3 つの構成要素から成る:

| 要素 | 役割 |
|---|---|
| [`exact_hooks/`](exact_hooks/) | Bash 実行イベントを atuin に記録するフック群 / SessionStart でメインエージェントに使い方案内を注入 |
| [`recall-commands` スキル](exact_skills/exact_recall-commands/SKILL.md) | atuin CLI の罠を回避した正しいクエリ組み立て方を集約 |
| [`command-history-analyzer` エージェント](exact_agents/command-history-analyzer.md) | atuin 履歴を整理してメインに返す読み取り専用エージェント。生出力でメインコンテキストを汚さない |

## 記録 — フック群

[hook 定義]では下表 4 イベントを登録する。`Bash` matcher の 3 つは[ラッパースクリプト]を経由して `atuin hook claude-code` を呼び、`SessionStart` は別の[セッション開始フック]がメインエージェントへの案内を `additionalContext` で注入する。

| Event | matcher | 動作 |
|---|---|---|
| `PreToolUse` | `Bash` | `tool_input.command` を stdin で受け取り、`history start --author claude` 相当を実行 |
| `PostToolUse` | `Bash` | `tool_response.stdout` / `exit_code` を stdin で受け取り、`history end` 相当を実行 |
| `PostToolUseFailure` | `Bash` | 同上 (失敗系イベント) |
| `SessionStart` | (なし) | メインに対し、atuin 利用案内・[`command-history-analyzer`](exact_agents/command-history-analyzer.md) / [`session-analyzer`](../exact_session-analyzer/exact_agents/session-analyzer.md) との役割分担・直接叩く vs エージェント経由の使い分けを `additionalContext` で注入 |

### Claude Code セッション ID の記録

[ラッパースクリプト]は stdin JSON から `session_id` を `jq` で抜き、`ATUIN_SESSION` 環境変数に詰めてから `atuin hook claude-code` に転送する。atuin の `History::new` は `ATUIN_SESSION` を `session` フィールドの値として採用するため、追加スキーマ無しで Claude Code セッション ID が `{session}` に乗る。

これにより `ATUIN_SESSION=<id> atuin history list --session --format '{time}|{session}|{command}'` のような形で、Claude Code セッション単位の履歴絞り込みが可能になる。実用クエリの詳細は [`recall-commands` スキル][recall-commands] を参照。

なお `atuin hook <agent>` は `atuin hook --help` に出ない隠しコマンドで、agent 名で挙動を分岐させる仕組み。Claude Code 用ハンドラは [Atuin AI Agent Hooks ドキュメント](https://docs.atuin.sh/cli/guide/agent-hooks/) に記載がある。handler 本体は stdin JSON の `session_id` を読み捨てる (atuin v18.16.0 時点) ため、ラッパーで補っている。

[hook 定義]: exact_hooks/hooks.json
[ラッパースクリプト]: exact_hooks/executable_atuin-hook.sh
[セッション開始フック]: exact_hooks/executable_session-start.sh
[recall-commands]: exact_skills/exact_recall-commands/SKILL.md

## クエリ — `recall-commands` スキル

`atuin` CLI には `--help` やドキュメントに載っていない挙動 / 設計上のバグが複数あり、素直に使うと欲しい結果が得られない。`recall-commands` スキルはそれらを集約した「正しいクエリ組み立て方」のリファレンス:

- 特定セッション ID の履歴取得は `atuin history list --session` (`atuin search --filter-mode session` は `ATUIN_SESSION` を見ない)
- 部分一致は `atuin search --search-mode full-text` (デフォルトの prefix モードはマッチしない時に最新コマンドをノイズとして返してくる)
- `--before` / `--after` の値はタイムゾーン非明示時 UTC 解釈される ([atuin issue #2808](https://github.com/atuinsh/atuin/issues/2808))。常に ISO 8601 + ローカル TZ オフセットを付ける
- `atuin history list` には `--limit` が無い。`head -N` / `tail -N` で外側から
- `atuin search` の `--format` ヘルプには `{session}` が載っていないが、実際は機能する (undocumented)

詳細・例・ユースケース別の組み立ては [`recall-commands` スキル][recall-commands] を参照。

## メイン保護 — `command-history-analyzer` エージェント

atuin の生出力は数千〜数万行になりうる。メインエージェントが直接 Bash で叩くとそれがメインコンテキストに乗り続けて context window を圧迫する。`command-history-analyzer` は **生出力をエージェント側に閉じ込め、メインには整理されたサマリだけ返す** ための読み取り専用エージェント:

- モデルは `haiku` (整形・集約は haiku で十分という想定。複雑な解釈が必要な場面が見つかれば sonnet 引き上げを検討)
- `tools` は `Bash` のみ (atuin CLI 叩く以外の権限を持たない)
- `skills: ["atuin:recall-commands"]` フロントマターで上記スキルをプリロード。起動時点で罠回避クエリの組み立てを身に着けた状態

メインエージェントが「メインで直接叩くか / エージェントに委ねるか」を判断できるよう、[セッション開始フック]の `additionalContext` で次の使い分け方針を事前告知している:

- メインで直接叩いて構わない場面: 現セッションの直前数件 / 1 件の確認 / 1 回限りの軽量クエリ
- エージェント経由を推奨する場面: 検索範囲が広い / 複数クエリの組合せ / 時間範囲俯瞰 / 複数 session の突き合わせ / `session-analyzer` 連携を含むチェーン

### `session-analyzer` との役割分担

| エージェント | 担当する情報 | データソース |
|---|---|---|
| [`atuin:command-history-analyzer`](exact_agents/command-history-analyzer.md) | Bash 実コマンド列 (実際に何を打ったか・引数・終了コード・時刻) | atuin DB |
| [`session-analyzer:session-analyzer`](../exact_session-analyzer/exact_agents/session-analyzer.md) | 会話 transcript (なぜそれをやったか・どんな思考を経たか) | `~/.claude/projects/*/<session-id>.jsonl` |

両者は同じ session ID で突き合わせられる。コマンド断片しか手がかりが無いとき、`command-history-analyzer` で session ID を逆引きしてから `session-analyzer` に渡す、というチェーンが自然。

## なぜプラグイン化したか

`atuin hook install claude-code` は便利だが、`~/.claude/settings.json` を直接書き換える上に、書き戻し時に JSON のキーがアルファベット順に再整形される副作用がある。chezmoi 管理下では差分が大きくなりやすく、ソース/実体の往復で揺らぐ。

プラグイン化することで:

- 設定は `hooks.json` に閉じ、`settings.json` を汚さない
- ON/OFF を `enabledPlugins` で切り替えられる
- 他マシン / 他プロジェクトへの展開が `enabledPlugins` の 1 行追加だけで済む
- ラッパースクリプトを差し込める場所が手に入る (= Claude Code セッション ID 記録の余地)

## 必要なもの

- atuin v18.16.0 以降 (`atuin hook` サブコマンドの導入バージョン) が PATH 上にあること
- `jq` が PATH 上にあること ([ラッパースクリプト]が stdin JSON のパースに使用)
