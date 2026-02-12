---
name: creating-topic-branches
description: トピックブランチの作成を行う時に使用する。
---

# Creating Topic Branches

作業を開始する際は次のコマンドを使用してデフォルトブランチからトピックブランチを作成します:

```bash
git create-topic-branch <topic-branch-name>
```

ブランチ名は作業内容に応じて Conventional Commits のタイプに準じたプレフィックスを使用します:

- `feat/<kebab-case-description>` - 新機能
- `fix/<kebab-case-description>` - バグ修正
- `refactor/<kebab-case-description>` - リファクタリング
- `docs/<kebab-case-description>` - ドキュメント
- `chore/<kebab-case-description>` - メンテナンス
