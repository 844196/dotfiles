# skills

## commit / commit-headless / commit-amend / commit-amend-headless

スキルの本文は `../../.chezmoitemplates/` 配下のテンプレートを使用しており、frontmatter のみ異なる。commit 系は `commit-skill-body.md`、amend 系は `commit-amend-skill-body.md` を参照する。各テンプレートには `dict` 関数で `interactive` フラグを渡し、対話用 (`true`) / 非対話用 (`false`) でテンプレート内の振る舞いを分岐させている。対話用スキルではステージ済みの変更がない場合に未ステージの変更を自動ステージする。

| スキル | モード | `context: fork` | 用途 |
|---|---|---|---|
| `commit` | commit | あり | 対話セッション内で `/commit` として使用。fork によりメインのコンテキストを汚染しない。 |
| `commit-headless` | commit | なし | ターミナルから `git claude-commit` 経由で使用。`--output-format stream-json` で途中経過をストリーミングする。 |
| `commit-amend` | amend | あり | 対話セッション内で `/commit-amend` として使用。直前のコミットを修正する。 |
| `commit-amend-headless` | amend | なし | ターミナルから `git claude-commit --amend` 経由で使用。直前のコミットを修正する。 |

`context: fork` を指定すると `--output-format stream-json` で `type: "assistant"` イベントがストリームされず、最終結果のみが `type: "result"` で返される。このため、ストリーミング出力が必要なヘッドレスモードでは fork を外している。

SEE ALSO: `../../exact_dot_844196/exact_bin/executable_git-claude-commit`
