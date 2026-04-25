---
paths:
  - files/**
---

# chezmoi ソース編集の規範

このリポジトリは chezmoi で管理されている dotfiles です。ソースを編集する際は以下に従います。

## ターゲットとソースの区別

- ターゲット (`~/` 以下) を直接編集しません。常にソース (`files/` 以下) を編集します。
- ソースを編集しても `chezmoi apply` を実行するまではターゲットに影響しないので、`files/` 以下のファイルは追加・編集・削除を自由に行ってかまいません。
- ターゲット側にある既存ファイルをソース管理下に取り込むときは `chezmoi add` を使わず、手でコピーします (ツールが `~/.config/<tool>/...` に吐いた設定を `files/dot_config/<tool>/...` へコピーする形)。

## 差分確認と apply の発火

- 差分確認は `mise run //:diff` を使います (`chezmoi diff --exclude scripts` のラッパー、ライフサイクルスクリプトのノイズを除外)。
- `.chezmoiignore` を編集したときの効果確認は `chezmoi ignored` (target 相対パスで一覧)。
- ターゲットへの反映は `mise run //:apply` を使います (`GITHUB_TOKEN=$(gh auth token) chezmoi apply` のラッパー)。`files/.chezmoiscripts/run_after_08-setup-mise.sh` が `mise install` / `mise upgrade` を経由して GitHub API を大量に呼ぶため、`GITHUB_TOKEN` なしでは即座にレートリミットに到達します。
- 生の `chezmoi apply` は `.claude/settings.json` で `deny` されています。エージェントから直接呼び出さず、常に `mise run //:apply` を使ってください。
- `mise run //:apply` は `.claude/settings.json` の `permissions.ask` に登録済みです。エージェントから発火し、ユーザーの確認を経て実行されます。
- 管理対象ツールが稼働中に apply すると壊れる可能性があるため、実行タイミングの判断はユーザーが握ります。エージェントは `ask` で止まる前提で発火してかまいません。

## ターゲット側の削除・リネーム

ソースから削除/リネームしても、親ディレクトリが `exact_` でなければターゲットには伝播しません (例: `dot_claude/` は非 `exact_`)。明示的にターゲットから消したい場合は `files/.chezmoiremove` を一時作成 (`~/` 相対パスで列挙) → `mise run //:apply` → `.chezmoiremove` 削除、の順で行います。コミット履歴を汚さずに削除を反映できます。

`dot_claude/exact_skills/` のように `exact_` 配下に外部ツール (apm 等) も配置する場合は、`.chezmoiignore` で外部ぶんを除外しつつ chezmoi 管理ぶんは exact 削除に任せるパターンを取ります (詳細: `.claude/rules/dot-apm.md`)。

どのディレクトリが `exact_` か、なぜそうなっているかは `docs/chezmoi-layout.md` の「`exact_` を付けるか外すか」を参照してください。

## `files/` 配下の `CLAUDE.md` は置かない

`files/` の中身はそのまま `~/` にコピーされるため、`files/<somewhere>/CLAUDE.md` をソース側に置くと、Claude Code がこのリポジトリ配下で起動したときにも (本来はターゲット側の memory として書いたはずの) その CLAUDE.md を nested memory として拾ってしまいます。

そのため `files/` 配下では以下のルールに統一します:

- ソース側エージェントへの指示 (「この `files/<dir>/` を編集するときの注意」) は、リポジトリ直下の `.claude/rules/<name>.md` に paths frontmatter (`paths: [files/<dir>/**]`) 付きで書きます。`files/<dir>/CLAUDE.md` は作りません。
- ターゲット側 (`~/`) で memory として読ませたい CLAUDE.md (例: `~/.claude/CLAUDE.md`) が必要な場合は、ソース上は `literal_CLAUDE.md` という名前で置きます。chezmoi の `literal_` prefix が外れて `CLAUDE.md` として配置されつつ、ソース側でのファイル名は `CLAUDE.md` ではなくなるので、このリポジトリのエージェントに誤読されません。
- `files/` 以外 (`packages/`、リポジトリ直下など) では、通常通り nested `CLAUDE.md` を使ってかまいません。`files/` 限定の制約です。

## `.chezmoiexternal.yaml` は最終手段

外部からファイルを取り込むときの優先順位:

1. **mise** で管理できるものは mise で管理する
2. **apm** (`files/dot_apm/apm.yml`) で管理できるものは apm で管理する
3. 上記いずれも不可能なときだけ `.chezmoiexternal.yaml` を使う

`.chezmoiexternal.yaml` に追加するのは、zsh プラグイン・tarball 展開が絡むもの・mise や nvim プラグインマネージャなど取り込み手段自体を提供するもの、といった「他に手段がない」ケースに限ります。

バージョン更新 (URL の tag / commit hash の書き換え) はユーザーの明示指示があるときのみ行います。pin している意図を尊重し、エージェントが勝手にアップデートしません。

例外として `Piebald-AI/claude-code-system-prompts` のタグは Claude Code CLI のバージョンに連動するため、`files/dot_config/exact_mise/config.toml` の `claude` を変更するときは `.chezmoiexternal.yaml` 側のタグも同じバージョンに揃えます。

## `.chezmoiscripts/` の方針

- `run_once_*` は使いません。初回限定の処理は `install.sh` に書き、再実行が必要な処理は `run_onchange_*` で表現します。
- 追加・編集・削除は自由に行ってかまいません (apply をユーザーが握っているため、ソース側の変更は即座にはターゲットに影響しません)。
- 命名規則・用途・番号の扱いは `docs/chezmoi-layout.md` を参照。

## 編集を避けるファイル

以下はユーザーの明示指示があるときのみ編集します:

- `wk.bindings.yaml` — 独自の which-key 風キーバインド設定。他の変更のついでに項目を足さないでください
- `install.sh` — chezmoi 本体の bootstrap。chezmoi のバージョン変更時のみ触ります
- `Dockerfile`, `compose.yaml` — `install.sh` のデバッグ用まっさらな環境の定義。このリポジトリが前提とするサポート環境の宣言を兼ねています
- `mise.local.toml` — 個人環境別の設定 (現状は GitHub アカウント別の `GITHUB_TOKEN` 払い出し設定)

## 参考

- リポジトリの全体像と編集権限マトリクス: `CLAUDE.md`
- `files/` 内部構造・プレフィックス・テンプレート・`.chezmoiscripts/`・`.chezmoiexternal.yaml` の詳細: `docs/chezmoi-layout.md`
