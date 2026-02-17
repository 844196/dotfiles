# ~/.claude/CLAUDE.md

このガイドラインはユーザーレベルです。

## コマンド実行時の注意点

エージェントが自走できるように設定で多くのコマンド実行が事前に許可されています。設定のグロブパターンが適切に機能するよう、以下の点に注意します:

- CWDは常にプロジェクトルートであると仮定します。不必要な `cd` を避けます。

  ```bash
  # Good
  mkdir -p dir
  ```

  ```bash
  # Bad
  cd <プロジェクトルート> && mkdir -p dir
  ```

- Gitコマンドはそのまま実行します。不必要な `-C` オプションや無用なプロジェクトルートへの `cd` を避けます。

  ```bash
  # Good
  git log --oneline
  ```

  ```bash
  # Bad
  cd <プロジェクトルート> && git log --oneline
  git -C <プロジェクトルート> log --oneline
  ```

- 複数行のコミットメッセージを伴う `git commit` は `-m` オプションを複数回指定する形式を使用します。ヒアドキュメントは避けます。

  ```bash
  # Good
  git commit -m "title" -m "paragraph" -m "paragraph" -m "Co-Authored-By: ..."
  ```

  ```bash
  # Bad
  git commit -F- <<EOM
  title

  paragraph

  paragraph

  Co-Authored-By: ...
  EOM
  ```

## コード探索時の注意点

- いきなりコードベース全体を読み込んで検索するのではなく、プロジェクトルートや関連するネストしたディレクトリ内の `CLAUDE.md` や `AGENTS.md` を確認し、ディレクトリ構造を把握します。
- TypeScriptプロジェクトでは `/exploring-typescript-code` スキルを使用します。

## 作業計画作成時の注意点

- 既存のドキュメントの更新や新規作成も計画に盛り込み、ドキュメントの陳腐化を防ぎます。

## バグ修正時の注意点

- 報告内容から自明な場合を除き、まず報告された問題を再現することに注力します。

## Pull Request作成時の注意点

- `/creating-pull-requests` スキルを使用します。

## 開発ドキュメント作成・更新時の注意点

- `/writing-dev-docs` スキルを使用します。
