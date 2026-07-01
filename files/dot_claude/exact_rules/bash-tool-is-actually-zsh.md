# Bash ツールの実体は zsh

Bash ツールは名前に反して zsh で実行される。ツールの起動プロセスは `zsh -c 'source <shell-snapshot> && setopt NO_EXTENDED_GLOB NO_BARE_GLOB_QUAL && eval <コマンド>'` の形。

このため bash 前提で書いたコマンドが zsh 側の仕様で意図せぬ挙動になるケースがある。以下の点を守る。

## zsh の tied array parameter に代入しない

zsh には「大文字のコロン区切りスカラー」と「小文字の配列」が array-tied になっている特殊パラメータがある。小文字版にスカラーを代入すると、対応する大文字版 (環境変数) が破壊される。

代表例:

| 小文字 (配列) | 大文字 (コロン区切り) |
|---|---|
| `path` | `PATH` |
| `cdpath` | `CDPATH` |
| `fpath` | `FPATH` |
| `manpath` | `MANPATH` |
| `mailpath` | `MAILPATH` |
| `module_path` | `MODULE_PATH` |
| `watch` | `WATCH` |
| `psvar` | `PSVAR` |

**NG:**
```bash
path=/tmp/work.txt  # PATH が /tmp/work.txt に破壊され、以降のコマンド解決が全滅する
```

**OK:**
```bash
file=/tmp/work.txt
tmp=/tmp/work.txt
work_path=/tmp/work.txt  # 大文字化・プレフィックス付与で衝突を回避
```

作業用の一時変数には `file`, `tmp`, `target`, `dest`, `out` など generic な名前を使う。どうしても "path" という語を含めたい場合は大文字にするかプレフィックスを付ける。

## zsh の read-only / 特殊変数に代入しない

- `status` (= `$?` と等価、read-only)
- `pipestatus` (bash の `PIPESTATUS` に相当、read-only)
- `LINENO`, `SECONDS`, `RANDOM`, `EPOCHSECONDS` (代入自体は可能だが zsh が動的更新するため上書きしても保たれない)
- `HISTCHARS`, `HISTORY` など履歴系

作業用スカラーには使わない。

## bash 固有構文を書くときは動作確認する

以下は bash 前提の構文。zsh でも動くものと動かないものが混在するので、使う前にワンライナーで挙動確認する。

- `declare -A` (連想配列) — zsh では `typeset -A`
- `mapfile` / `readarray` — zsh には存在しない
- `read -a arr` — zsh では `read -A arr`
- `${var,,}` / `${var^^}` (大小変換) — zsh でも動くが `${(L)var}` / `${(U)var}` が zsh 流
- 配列インデックス — bash は 0-based、zsh は 1-based
- `shopt` — zsh に存在しない (zsh は `setopt`)

## どうしても bash が必要な場合

明示的に `bash -c '...'` で包む。デフォルトの選択肢ではなく、上記で回避できないときの exception として使う。

```bash
bash -c 'declare -A map=([a]=1 [b]=2); echo "${map[a]}"'
```

## 背景

Bash ツールという名前と、システムプロンプトの "bash command" という説明から、実行シェルも bash だと思い込みやすい。実際に `ps -p $$ -o args` で観測すると `zsh -c ...` で起動されていることが確認できる。ラッパは `NO_EXTENDED_GLOB` / `NO_BARE_GLOB_QUAL` を落として glob 挙動を bash に寄せているが、それ以外の差分はカバーされない。
