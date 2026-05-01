---
name: update-claude
description: Claude Code を最新または指定バージョンにアップデートする。mise と chezmoi を使って claude CLI と claude-code-system-prompts の両方を同期的に更新し、CLI 公式チェンジログとシステムプロンプトのチェンジログを併せて要約する。「claude をアップデート」「claude を最新に」「/update-claude」「claude を X.Y.Z に」といった指示で発動する。
---

# Claude Code アップデート

Claude Code (CLI) と抽出されたシステムプロンプト (Piebald-AI/claude-code-system-prompts) を同期的に更新する。

## 引数

- 引数なし: 最新バージョンへアップデート
- `X.Y.Z`: 指定バージョンへアップデート

## ワークフロー

### 1. 設定ファイルの更新

まず `claude --version` で **アップデート前のバージョン** を控えておく (ステップ 3 でチェンジログ範囲を決めるのに使う)。

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

旧バージョンを `X.Y.Z`、新バージョンを `A.B.C` とする (ステップ 1 で控えた値とステップ 1 のスクリプト出力で確認できる)。控え忘れた場合の保険として、`git log -p files/.chezmoidata.json` で直前のコミットの値を参照できる。

このステップでは 2 系統のチェンジログを取得する:

1. **Claude Code CLI 公式チェンジログ** — CLI 自体の機能・バグ修正・破壊的変更
2. **システムプロンプトのチェンジログ** — Piebald-AI が抽出している system prompts / system reminders / tool descriptions / built-in skills の差分。CLI 公式には載らない (もしくは載っていても粒度が荒い) 詳細が含まれる

両方を独立に取得した後、最後にまとめて要約する。

#### 3-a. CLI 公式チェンジログを取得

```
WebFetch https://code.claude.com/docs/en/changelog
prompt: "前バージョン X.Y.Z から新バージョン A.B.C までの間に追加された全エントリを、バージョンごとにそのまま列挙してほしい。要約せず原文の bullet をそのまま残すこと。"
```

公式 changelog はリリースしたバージョン全てのエントリを掲載しているとは限らない (システムプロンプト変更のみのバージョンや、内部的な修正のみのバージョンはスキップされることがある)。`X.Y.Z` と `A.B.C` の間の中間バージョン (`X.Y.Z+1` 等) のエントリが見当たらなくてもエラーにしない。

#### 3-b. システムプロンプトのチェンジログを取得

システムプロンプトの抽出物 (Piebald-AI/claude-code-system-prompts) は `claude-code-meta:claude-code-meta` スキルが所管している。**このスキル側ではファイルパスをハードコードしない。** `claude-code-meta` の references 配置は将来変わる可能性があるため、毎回 `claude-code-meta:claude-code-meta` 経由で解決する。

手順:

1. `Skill` ツールで `claude-code-meta:claude-code-meta` を呼び出してロードする (引数は `システムプロンプトのチェンジログを確認` 等の自然な指示でよい)
2. ロードされた SKILL.md 本文に references の所在 (CHANGELOG.md のパス) が記載されているので、それを読む
3. 旧バージョン `X.Y.Z` (排他) から新バージョン `A.B.C` (含む) までのエントリを抽出する

注意点:

- システムプロンプトの CHANGELOG は CLI のリリースサイクルと厳密には一致しない。あるバージョンでシステムプロンプト無変更ならエントリが省略される (例: `_+0 tokens_` で「No changes」と書かれるか、エントリ自体が無いか)
- README が新バージョンに言及していても CHANGELOG エントリが追いついていないことがある。その場合は「CHANGELOG 未記載」と明示する
- `git log -p` で `references/claude-code-system-prompts/system-prompts/` 配下の差分を見ると、CHANGELOG に書かれていないファイルの追加・削除を捕捉できる (例: 過去には Read tool の malware reminder が CHANGELOG エントリなしでファイルから削除された)

#### 3-c. 統合して要約

3-a と 3-b で得たエントリを以下の 3 軸で分類してユーザーに伝える:

##### 主要な変更 (CLI 公式)

ユーザー体験に直接影響する大きめの変更を 3〜7 件程度で抜粋する。判定基準:
- 新機能の追加 (新しいコマンド、サブエージェント機能、ツール等)
- 既存挙動のデフォルト変更
- パフォーマンスやコスト面の大きな改善
- 廃止予定 / 破壊的変更

##### システムプロンプトの変更

CLI 公式に載らない (もしくは載っていても粒度が荒い) システムプロンプト側の変更を抜粋する。観点:
- 新規追加された system prompt / system reminder / tool description / built-in skill
- 既存プロンプトの大きな書き換え (token 増減が大きい、変数構造が変わった等)
- 削除されたプロンプト (Claude の挙動変化に直結する)
- ツール記述の文言変更 (Claude の使い方に影響しうるもの)

CHANGELOG にエントリがない場合でも、ファイル単位の追加・削除が `chezmoi diff` や `git log -p` で確認できれば併記する。

##### この dotfiles に関係・影響しそうなもの

このリポジトリ固有の運用に効きそうな変更を抜粋する。観点:
- `settings.json` / `settings.local.json` の新キー、廃止キー、デフォルト値変更 (このリポジトリは `files/dot_claude/` 配下に同期している)
- hooks の仕様変更 (`PreToolUse` / `PostToolUse` / `UserPromptSubmit` 等のスキーマやイベント追加)
- スキル機能 (`paths` フロントマター、`${CLAUDE_SESSION_ID}` 等の文字列置換、`!` プリプロセッシング、`SKILL.md` 評価タイミング) の変更
- 組み込みスキル / slash command の追加・改名・廃止 (このリポジトリのカスタムスキルと衝突する可能性)
- 環境変数 (`CLAUDE_*`) の追加・変更
- mise / chezmoi 連携や XDG 準拠に響く変更 (設定ファイルパス、状態ファイル位置等)
- WSL2 / macOS 固有の挙動差分

該当が無さそうな場合はその旨だけ伝える (無理に該当を作らない)。判断に迷うものは「念のため」枠として軽く触れる。

出力形式:

```
## 主要な変更 (CLI 公式)
- [vA.B.C] xxx
- [vA.B.D] yyy

## システムプロンプトの変更
- [vA.B.C] NEW: zzz
- [vA.B.C] REMOVED: www
- [vA.B.C] 変更: vvv

## この dotfiles に関係・影響しそうなもの
- [vA.B.C] uuu
  - 影響しそうなパス: files/dot_claude/settings.json
  - 対応案: ...
```

該当箇所のリポジトリ内パスや、具体的な対応の見通しがあれば併記する。実際のファイル変更はユーザーの指示を待つ (このスキルでは行わない)。

## ダウングレード

古いバージョンへのダウングレードも可能。ただし、旧バージョンの claude-code-system-prompts を 1 回でもこのスキルでインストール済みの場合、システムプロンプトの差分が `chezmoi diff` に現れることがある。
