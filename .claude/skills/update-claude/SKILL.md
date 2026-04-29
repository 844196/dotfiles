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

まず `claude --version` で **アップデート前のバージョン** を控えておく (ステップ 4 でチェンジログ範囲を決めるのに使う)。

次に `$ARGUMENTS` を確認する。引数は以下のいずれか:
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
chezmoi diff
chezmoi apply
```

chezmoi でエラーが発生した場合、このスキル以外の問題 (ディスク容量、権限、他の chezmoi 設定の問題など) が原因である可能性が高い。ユーザーに確認を促す。

### 3. チェンジログの取得と要約

アップデート前後のバージョンを把握した状態で、公式チェンジログを取得する:

```
WebFetch https://code.claude.com/docs/en/changelog
prompt: "前バージョン X.Y.Z から新バージョン A.B.C までの間に追加された全エントリを、バージョンごとにそのまま列挙してほしい。要約せず原文の bullet をそのまま残すこと。"
```

`X.Y.Z` はステップ 1 で控えた旧バージョン、`A.B.C` はステップ 3 で確認した新バージョン。控え忘れた場合の保険として、`git log -p files/.chezmoidata.json` で直前のコミットの値を参照できる。

取得したエントリを以下の 2 軸で分類してユーザーに伝える:

#### 主要な変更

ユーザー体験に直接影響する大きめの変更を 3〜7 件程度で抜粋する。判定基準:
- 新機能の追加 (新しいコマンド、サブエージェント機能、ツール等)
- 既存挙動のデフォルト変更
- パフォーマンスやコスト面の大きな改善
- 廃止予定 / 破壊的変更

#### この dotfiles に関係・影響しそうなもの

このリポジトリ固有の運用に効きそうな変更を抜粋する。観点:
- `settings.json` / `settings.local.json` の新キー、廃止キー、デフォルト値変更 (このリポジトリは `files/dot_claude/` 配下に同期している)
- hooks の仕様変更 (`PreToolUse` / `PostToolUse` / `UserPromptSubmit` 等のスキーマやイベント追加)
- スキル機能 (`paths` フロントマター、`${CLAUDE_SESSION_ID}` 等の文字列置換、`!` プリプロセッシング、`SKILL.md` 評価タイミング) の変更
- 組み込みスキル / slash command の追加・改名・廃止 (このリポジトリのカスタムスキルと衝突する可能性)
- `claude-code-system-prompts` 抽出に影響するプロンプト構造の変化 (`~/.claude/rules/claude-code-system-prompts.md` 参照)
- 環境変数 (`CLAUDE_*`) の追加・変更
- mise / chezmoi 連携や XDG 準拠に響く変更 (設定ファイルパス、状態ファイル位置等)
- WSL2 / macOS 固有の挙動差分

該当が無さそうな場合はその旨だけ伝える (無理に該当を作らない)。判断に迷うものは「念のため」枠として軽く触れる。

出力形式:

```
## 主要な変更
- [vA.B.C] xxx
- [vA.B.D] yyy

## この dotfiles に関係・影響しそうなもの
- [vA.B.C] zzz
  - 影響しそうなパス: files/dot_claude/settings.json
  - 対応案: ...
```

該当箇所のリポジトリ内パスや、具体的な対応の見通しがあれば併記する。実際のファイル変更はユーザーの指示を待つ (このスキルでは行わない)。

## ダウングレード

古いバージョンへのダウングレードも可能。ただし、旧バージョンの claude-code-system-prompts を 1 回でもこのスキルでインストール済みの場合、システムプロンプトの差分が `chezmoi diff` に現れることがある。
