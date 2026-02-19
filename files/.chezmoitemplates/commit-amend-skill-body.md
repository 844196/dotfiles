# Amending the Last Commit

直前のコミットを修正 (amend) します。ユーザーへの確認なしに直接 amend コミットを実行することが許可されています。

## 手順
{{ if .interactive }}

### 0. 未ステージの変更を自動ステージ

`git status --short` を実行して未ステージの変更を確認します。未ステージの変更がある場合は `git add` でステージしてから amend フローを続行します。
{{ end }}
### 1. 直前のコミットと差分を確認

直前のコミットメッセージ:
!`git log -1 --format=%B`

amend 後に含まれる全差分の `--stat`:
!`git diff HEAD~1 --cached --stat`

amend 後に含まれる全差分:
!`git diff HEAD~1 --cached`

### 2. コミットメッセージ規約の把握

次の優先度でプロジェクトのドキュメントを確認し、コミットメッセージ規約を把握します:

1. `CLAUDE.md` ファイルの内容
2. `AGENTS.md` ファイルの内容
3. `CONTRIBUTING.md` ファイルの内容

プロジェクトのドキュメントにコミットメッセージ規約が見つからない場合は、直近のコミット履歴を確認して規約を推測します。

```bash
git log --oneline -10
```

### 3. コミットメッセージの生成

直前のコミットメッセージ、amend 後に含まれる全差分の内容、コミット履歴から読み取れる規約、そしてユーザーから追加の説明がある場合はそれも考慮し、プロジェクトの規約に沿ったコミットメッセージを生成します。

**ルール:**
- コミットメッセージは !`git commit-language` で生成する
- subject は変更の目的を簡潔に表す
- body は原則不要。変更の意図が subject だけでは伝わらない場合のみ付与する

ユーザーからの追加の説明:
$ARGUMENTS

### 4. コミットの実行

```bash
git commit --amend -m '<title>' [-m $'paragraph-line\nparagraph-line'] [-m $'paragraph-line\nparagraph-line'] -m 'Co-Authored-By: ...'
```

### 5. 完了報告

次のフォーマットで修正 (amend) が完了したことをユーザーに報告します:

```
修正 (amend) が完了しました
~~~
<タイトル・本文・フッターを含む完全なコミットメッセージ>
~~~
```
