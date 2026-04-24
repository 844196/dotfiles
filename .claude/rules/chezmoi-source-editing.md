# chezmoi ソース編集の規範

このリポジトリは chezmoi で管理されている dotfiles です。ソースを編集する際は以下に従います。

## ターゲットとソースの区別

- ターゲット (`~/` 以下) を直接編集しません。常にソース (`files/` 以下) を編集します。
- ソースを編集しても `chezmoi apply` を実行するまではターゲットに影響しないので、`files/` 以下のファイルは追加・編集・削除を自由に行ってかまいません。
- ターゲット側にある既存ファイルをソース管理下に取り込むときは `chezmoi add` を使わず、手でコピーします (ツールが `~/.config/<tool>/...` に吐いた設定を `files/dot_config/<tool>/...` へコピーする形)。

## 差分確認と apply の発火

- 差分確認は `mise run //:diff` を使います (`chezmoi diff --exclude scripts` のラッパー、ライフサイクルスクリプトのノイズを除外)。
- ターゲットへの反映は `mise run //:apply` を使います (`GITHUB_TOKEN=$(gh auth token) chezmoi apply` のラッパー)。`files/.chezmoiscripts/run_after_08-setup-mise.sh` が `mise install` / `mise upgrade` を経由して GitHub API を大量に呼ぶため、`GITHUB_TOKEN` なしでは即座にレートリミットに到達します。
- 生の `chezmoi apply` は `.claude/settings.json` で `deny` されています。エージェントから直接呼び出さず、常に `mise run //:apply` を使ってください。
- `mise run //:apply` は `.claude/settings.json` の `permissions.ask` に登録済みです。エージェントから発火し、ユーザーの確認を経て実行されます。
- 管理対象ツールが稼働中に apply すると壊れる可能性があるため、実行タイミングの判断はユーザーが握ります。エージェントは `ask` で止まる前提で発火してかまいません。

## コミット

- エージェントは自発的にコミットしません。
- エージェントがコミットを実行するのは、ユーザーが「期待通り動いている」と確認したうえで、ユーザーから明示的な指示 (「コミットして」、コミット系スキルの呼び出し等) があったときだけです。
- コミットメッセージのフォーマットは Conventional Commits に従います (利用可能なタイプ/スコープは `.versionrc` を参照)。

## `.chezmoiexternal.yaml` は最終手段

外部からファイルを取り込むときの優先順位:

1. **mise** で管理できるものは mise で管理する
2. **apm** (`files/dot_apm/apm.yml`) で管理できるものは apm で管理する
3. 上記いずれも不可能なときだけ `.chezmoiexternal.yaml` を使う

`.chezmoiexternal.yaml` に追加するのは、zsh プラグイン・tarball 展開が絡むもの・mise や nvim プラグインマネージャなど取り込み手段自体を提供するもの、といった「他に手段がない」ケースに限ります。

バージョン更新 (URL の tag / commit hash の書き換え) はユーザーの明示指示があるときのみ行います。pin している意図を尊重し、エージェントが勝手にアップデートしません。

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
