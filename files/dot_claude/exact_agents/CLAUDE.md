# カスタムエージェント

`~/.claude/agents/` 内のカスタムエージェント定義に関する説明。

## wizard.md

Agent Teams 用の汎用エージェント。

### model: inherit の意図

Agent ツールで model を省略すると CLI リリース時点の最新モデルが使われる。しかし GCP Vertex AI 等の環境では、そのモデルが利用できない場合がある（例: Vertex AI で opus 4.7 が未提供）。

エージェント定義の frontmatter で `model: inherit` を指定すると、チームリード（親）と同じモデルで起動する。親が動いているモデルは環境で確実に利用可能なので、進行不能を回避できる。

この挙動は Agent ツールの model パラメータでは指定できない（enum に `inherit` がない）。エージェント定義ファイル専用。
