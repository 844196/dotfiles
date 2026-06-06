---
name: recall-commands
description: atuin に記録された Claude Code の Bash 実行履歴をサルベージするための「正しいクエリ組み立て方」リファレンス
---

# recall-commands

プラグインに組み込まれたフックによって Claude Code の Bash 実行履歴を `{session}` フィールドにセッション ID 紐付きで記録している。このスキルはその履歴を機械的に引くための「正しいクエリ組み立て方」を提供する。

`atuin` 単体の `--help` やドキュメントには載っていない挙動や、設計上のバグが複数あり、素直に使うと欲しい結果が得られない。検証で判明した使える組み合わせと、踏むと外れる罠をここに集約する。

## 共通のクエリ設計

### 出力フォーマット

後段で機械処理しやすいよう、pipe 区切りで `--format` を組む。ANSI 装飾は入らないので、そのままパイプに流せる。

利用可能なプレースホルダ (主要なもの):

- `{time}` — 実行時刻 (設定 TZ で表示)
- `{session}` — Claude Code セッション ID (UUID)
- `{command}` — 実行されたコマンド文字列
- `{exit}` — 終了コード (0 でない実行を絞りたいときに必須)
- `{directory}` — 実行ディレクトリ
- `{duration}` — 実行時間
- `{author}` — 実行者 (`claude-code` / 人間ユーザー名 / 他のエージェント名)

例: `--format '{time}|{session}|{exit}|{command}'`

### コマンドの選び方

| やりたいこと | 使う CLI |
|---|---|
| **特定セッション ID のコマンドだけ全件取りたい** | `atuin history list --session` (環境変数 `ATUIN_SESSION` 必須) |
| **コマンド文字列の部分一致で検索したい (逆引き含む)** | `atuin search --search-mode full-text` |
| **時間範囲・著者・終了コード・cwd で絞りたい** | `atuin search` (絞り込みフラグが豊富) |

セッション絞り込みと部分一致検索は **同じコマンドで両立できない** (理由は後述の罠 1)。session 絞り込みが必須なら history list、そうでなければ search を選ぶ。

## ユースケース 1 — 特定セッションの全履歴を取得

前セッション ID が分かっていて、その Bash 実行ログを丸ごと欲しいとき。

```bash
ATUIN_SESSION=<session-id> atuin history list --session \
  --format '{time}|{exit}|{command}'
```

注意点:

- `--session` フラグと `ATUIN_SESSION` 環境変数の **両方が必須**。フラグだけだと atuin のデフォルト zsh session で絞り込まれてしまう
- 出力は時刻昇順 (古い順)
- `atuin history list` には `--limit` フラグが **無い**。件数を絞るなら `| head -N` / `| tail -N` で外側から

現セッションを対象にする場合は、`ATUIN_SESSION` 環境変数がすでに存在するので `atuin history list --session ...` だけで OK。

## ユースケース 2 — コマンド断片から session ID を逆引き

「`chezmoi apply` を打った session があったはず」のように、コマンド文字列の断片しか手がかりがないとき、それを実行した Claude Code セッション ID を特定する。

```bash
atuin search --search-mode full-text \
  --format '{time}|{session}|{command}' \
  '<コマンド断片>'
```

注意点:

- `--search-mode full-text` を **必ず付ける**。デフォルト (`prefix`) と `fuzzy` は、クエリにマッチしないと無関係な最新コマンドをノイズとして返してくる (罠 2)
- `--format` のヘルプには `{session}` が載っていないが、実際は機能する (undocumented)
- session ID だけが欲しければ後段で `| awk -F'|' '{print $2}' | sort -u` で抽出

このスキルが確定させるのは「いつ・どの session で・どんなコマンドを」まで。逆引きした session ID を起点に当時の会話文脈まで辿る流れは別途まとめてある。

## ユースケース 3 — 時間範囲・著者・終了コードで俯瞰

「直近で claude-code が打った失敗コマンドだけ見たい」のような俯瞰。

```bash
atuin search --author 'claude-code' \
  --exclude-exit 0 \
  --after '2026-05-20T00:00:00+09:00' \
  --format '{time}|{exit}|{command}' \
  --limit 50
```

主な絞り込みフラグ:

- `--author 'claude-code'` — Claude Code が実行したコマンドのみ
- `--author '$all-agent'` — 任意のエージェント (claude-code 以外も含む)
- `--author '$all-user'` — 人間ユーザーが直接打ったもの
- `--exit N` / `--exclude-exit N` — 終了コードで絞り込み・除外
- `--cwd <path>` / `--exclude-cwd <path>` — 実行ディレクトリで絞り込み・除外
- `--after <時刻>` / `--before <時刻>` — 時間範囲。**書式は罠 3 を参照**
- `--limit N` — 件数制限 (search 側にはある。history list には無い)

## 罠 (atuin v18.16.0 で確認)

### 罠 1: `atuin search --filter-mode session` は `ATUIN_SESSION` を見ない

`--filter-mode session` を付けても、参照されるのは atuin の zsh セッション ID であって `ATUIN_SESSION` 環境変数ではない。つまり Claude Code セッション ID での絞り込みには **使えない**。

```bash
# 期待通りに動かない例 — Claude Code session ではなく atuin zsh session で絞られる
ATUIN_SESSION=<id> atuin search --filter-mode session
```

セッション絞り込みは `atuin history list --session` を使う (ユースケース 1)。

### 罠 2: search のデフォルト search-mode はクエリ不一致時にノイズを返す

`atuin search` のデフォルトは `--search-mode prefix`。これと `fuzzy` は、クエリ文字列にマッチするコマンドが無いときに、**無関係な最新コマンドを大量に返してくる**。コマンド断片で逆引きするには `full-text` モード一択。

```bash
# NG: 'chezmoiroot' を含まないコマンドが大量に混じる
atuin search 'chezmoiroot' --format '{session}|{command}'

# OK: 文字列を実際に含むコマンドだけ返る
atuin search --search-mode full-text 'chezmoiroot' --format '{session}|{command}'
```

### 罠 3: `--before` / `--after` は TZ 非明示時に UTC として解釈される

[atuin issue #2808](https://github.com/atuinsh/atuin/issues/2808) — `--before` / `--after` の値にタイムゾーンオフセットが含まれていないと、ローカル TZ ではなく **UTC として解釈される**。`--timezone` / `--tz` フラグを足してもこの解釈は上書きされない。

```bash
# NG (JST 環境で): UTC として解釈されるので、JST 23:55 のコマンドはマッチしない
atuin search --after '2026-05-20 23:55:00'

# NG: --timezone フラグも効かない
atuin search --tz +09:00 --after '2026-05-20 23:55:00'

# OK: 値側にオフセットを必ず明示する
atuin search --after '2026-05-20T23:55:00+09:00'
```

ユーザーや上流から「今日の 0 時以降」のような自然文で時刻を受け取ったら、まず ISO 8601 + ローカル TZ オフセットに変換してから atuin に渡す:

```bash
date -d 'today 00:00' -Iseconds  # 例: 2026-05-20T00:00:00+09:00
```

### 罠 4: `atuin history list` に `--limit` が無い

件数制限は `| head -N` / `| tail -N` で外側から行う。`--reverse` で時刻順を反転できるので、最新 N 件が欲しければ `--reverse=false` と組み合わせる手もある。

### 罠 5: `atuin search` の `--format` ヘルプには `{session}` が載っていない

`--help` の出力上は `{command}, {directory}, {duration}, {user}, {host}, {time}, {exit}, {relativetime}` だけが列挙されているが、**実際は `{session}` も機能する** (undocumented)。逆引きのキモなので気にせず使う。

## Claude Code セッション ID の取り方

| 取得元 | 方法 |
|---|---|
| 現セッション | 環境変数 `CLAUDE_CODE_SESSION_ID` |
| 前セッション | ユーザー提示・引き継ぎ文書など外部の手がかりから |
| コマンド断片しかないとき | ユースケース 2 で逆引き |
