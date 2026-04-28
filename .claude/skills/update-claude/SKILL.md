---
name: update-claude
description: Claude Code を最新または指定バージョンにアップデートする。mise と chezmoi を使って claude CLI と claude-code-system-prompts の両方を同期的に更新する。「claude をアップデート」「claude を最新に」「/update-claude」「claude を X.Y.Z に」といった指示で発動する。
---

# Claude Code アップデート

Claude Code (CLI) と抽出されたシステムプロンプト (Piebald-AI/claude-code-system-prompts) を同期的に更新する。

## 引数

- 引数なし: 最新バージョンへアップデート
- `X.Y.Z`: 指定バージョンへアップデート

## ワークフロー

### 1. 設定ファイルの更新

まず `$ARGUMENTS` を確認する。引数は以下のいずれか:
- 空: 最新バージョンへアップデート → `latest` を指定
- `X.Y.Z` 形式: そのバージョンへアップデート → そのまま指定

確認後、適切な引数でスクリプトを実行する:

```bash
.claude/skills/update-claude/scripts/update-chezmoidata.sh <version>
```

`<version>` は `latest` または `X.Y.Z` 形式のバージョン番号。

スクリプトが以下を実行する:
- 最新バージョンの取得 (npm レジストリ経由)
- システムプロンプトの利用可能性確認 (Piebald-AI/claude-code-system-prompts)
- `files/.chezmoidata.json` の更新

エラー終了した場合はユーザーに伝えて作業を中止する。よくあるケース:
- claude-code-system-prompts のリリースが数時間〜1日遅れる
- 古いバージョンは system-prompts リポジトリに存在しない可能性がある

### 2. chezmoi で反映

```bash
mise run //:chezmoi:diff
mise run //:chezmoi:apply
```

chezmoi でエラーが発生した場合、このスキル以外の問題 (ディスク容量、権限、他の chezmoi 設定の問題など) が原因である可能性が高い。ユーザーに確認を促す。

### 3. アップデート完了の確認

```bash
claude --version
```

期待したバージョンになっていることを確認する。

## ダウングレード

古いバージョンへのダウングレードも可能。ただし、旧バージョンの claude-code-system-prompts を 1 回でもこのスキルでインストール済みの場合、システムプロンプトの差分が `chezmoi diff` に現れることがある。
