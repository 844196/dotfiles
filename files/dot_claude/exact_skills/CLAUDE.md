# skills

## commit / commit-headless

両スキルの本文は `../../.chezmoitemplates/commit-skill-body.md` を共有しており、frontmatter のみ異なる。

| スキル | `context: fork` | 用途 |
|---|---|---|
| `commit` | あり | 対話セッション内で `/commit` として使用。fork によりメインのコンテキストを汚染しない。 |
| `commit-headless` | なし | ターミナルから `claude-commit` 経由で使用。`--output-format stream-json` で途中経過をストリーミングする。 |

`context: fork` を指定すると `--output-format stream-json` で `type: "assistant"` イベントがストリームされず、最終結果のみが `type: "result"` で返される。このため、ストリーミング出力が必要なヘッドレスモードでは fork を外している。

SEE ALSO: `../../dot_local/share/zsh/exact_functions/exact_Misc/claude-commit`
