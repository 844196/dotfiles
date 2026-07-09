---
name: headless-commit-amend
description: 直前のコミットを修正 (amend) する。コミットメッセージを自動生成し、amend コミットを実行する。
disable-model-invocation: true
model: haiku
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/git-claude-attribution)
---

# Amending the Last Commit

直前のコミットを修正 (amend) します。ユーザーへの確認なしに直接 amend コミットを実行することが許可されています。

## 手順

**注意:**
- CWD がリポジトリルートであることを前提とします。
- ステージは行いません。ステージはユーザーが事前に済ませている前提で、スキルはその時点で staged な内容のみを使って amend します (新たな `git add` を実行しない)。

### 1. 直前のコミットと amend 後の差分を確認

直前のコミットメッセージ:
!`git log -1 --format=%B`

amend 後に含まれる全差分の `--stat` (HEAD~1 から見た index):
!`git diff HEAD~1 --cached --stat`

amend 後に含まれる全差分:
!`git diff HEAD~1 --cached`

### 2. コミットメッセージ規約の把握

直近のコミット履歴からプロジェクトの規約を把握する:

```bash
git log --oneline -10
```

CLAUDE.md にコミットメッセージ規約があれば、既にコンテキストに含まれているのでそれに従う。

!`${CLAUDE_PLUGIN_ROOT}/scripts/git-claude-attribution`

### 3. コミットメッセージの生成

直前のコミットメッセージ、amend 後に含まれる全差分の内容、コミット履歴から読み取れる規約、そしてユーザーが渡した経緯メモ (`$ARGUMENTS`) を統合して、プロジェクトの規約に沿ったコミットメッセージを生成します。

**ルール:**

- コミットメッセージは${user_config.COMMIT_MESSAGE_LANGUAGE}で生成する
- subject は変更内容を簡潔に表す
- ユーザーが渡した経緯メモ (`$ARGUMENTS`) の扱い:
  - 経緯メモは **`git diff` には現れない情報** (なぜその変更を行ったか、どういう経緯か) を表すユーザー本人の言葉です。`git diff` から読み取れる「何を変えたか」とは独立した、捨てると失われてしまう情報なので、必ずコミットメッセージに反映してください。
  - 短くて subject の動機部分として収まるなら subject に組み込む。
    - 例: 経緯メモ `unused だから消した` → `refactor(foo): unused な bar を削除`
  - subject に収めると不自然になる、もしくは複数の文・複数の理由がある場合は body に書く。規約に沿う形に整えてよいが、ユーザーの意図は失わない。
    - 例: 経緯メモ `前任者が試験的に入れたが結局使われなかったので整理する` → subject に変更内容、body に経緯
- 経緯メモが空のときは body 原則不要 (subject だけで意図が伝わるケースが多いため)。subject だけでは意図が伝わらない大きな変更に限り body を付ける。

ユーザーが渡した経緯メモ:
$ARGUMENTS

### 4. コミットの実行

コミットメッセージを渡して `git commit --amend` を実行する。

### 5. 完了報告

次のフォーマットで修正 (amend) が完了したことをユーザーに報告します:

```
修正 (amend) が完了しました
~~~
<タイトル・本文・フッターを含む完全なコミットメッセージ>
~~~
```
