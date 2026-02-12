---
name: creating-pull-requests
description: gh CLIを使用してPull Requestを作成する。ベースブランチとの差分からPRタイトルと説明文を自動生成する。ユーザーがPR作成を依頼した時に使用する。
context: fork
---

# Creating Pull Requests

チェックリストをコピーして進捗を追跡します:

```
- [ ] Step 1: 変更内容の把握・整理
- [ ] Step 2: タイトルと説明文の作成
- [ ] Step 3: 作成ページを表示
- [ ] Step 4: ユーザーが最終確認
```

## Step 1: 変更内容の把握・整理

- ベースブランチ: !`git base-branch`
- コミットログ: !`git log-topic-branch`
- 変更内容: !`git diff-topic-branch`

## Step 2: タイトルと説明文の作成

**注意**: `.github/PULL_REQUEST_TEMPLATE.md` やプロジェクトごとのテンプレートが存在する場合は、そのテンプレートに従います。

### タイトル

変更の目的が一目でわかる、短く (70文字以内) 簡潔なタイトルを生成します。

### 説明文

**必ず含めるべきこと:**
- 変更の概要
- 変更するに至った背景、理由
- 変更によって実現されるもの
- 手元で行った動作確認内容や方法

**もしあるなら含めるべきこと:**
- 破壊的変更がある場合、その詳細、影響範囲、マイグレーションパス
- 関連する課題番号やチケットへのリンク

## Step 3: 作成ページを表示

```bash
gh pr create --web --assignee @me --base "<base-branch>" --title "<title>" --body "<body>"
```

エージェントの行う作業自体はここまでです。

## Step 4: ユーザーが最終確認

ユーザーが開かれた作成ページで内容を最終確認し、必要に応じて修正を加えた上でPull Requestを作成します。
