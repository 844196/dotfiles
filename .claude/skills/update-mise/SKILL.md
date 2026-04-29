---
name: update-mise
description: mise を最新または指定バージョンにアップデートする。chezmoi を使って mise のバージョンを更新する。「mise をアップデート」「mise を最新に」「/update-mise」「mise を X.Y.Z に」といった指示で発動する。
---

# mise アップデート

mise を指定バージョンに更新する。

## 引数

- 引数なし: 最新バージョンへアップデート
- `vX.Y.Z` または `X.Y.Z`: 指定バージョンへアップデート

## ワークフロー

### 1. 設定ファイルの更新

まず `$ARGUMENTS` を確認する。引数は以下のいずれか:
- 空: 最新バージョンへアップデート → `latest` を指定
- `vX.Y.Z` または `X.Y.Z` 形式: そのバージョンへアップデート → そのまま指定

確認後、適切な引数でスクリプトを実行する:

```bash
.claude/skills/update-mise/scripts/update-chezmoidata.sh <version>
```

`<version>` は `latest` または `vX.Y.Z` 形式のバージョン番号。

スクリプトが以下を実行する:
- 最新バージョンの取得 (gh で jdx/mise のリリースから)
- `files/.chezmoidata.json` の更新

エラー終了した場合はユーザーに伝えて作業を中止する。

### 2. chezmoi で反映

```bash
chezmoi diff
chezmoi apply
```

chezmoi でエラーが発生した場合、このスキル以外の問題 (ディスク容量、権限、他の chezmoi 設定の問題など) が原因である可能性が高い。ユーザーに確認を促す。

### 3. アップデート完了の確認

```bash
mise --version
```

期待したバージョンになっていることを確認する。

## ダウングレード

古いバージョンへのダウングレードも可能。
