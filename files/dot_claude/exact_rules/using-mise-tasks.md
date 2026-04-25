# mise タスクを実行する場合

- タスクの実行・定義・変更を行う際は `/using-mise-tasks` スキルを参照する
- プロジェクトルートに `mise.toml` がある場合、ビルド/テスト/リント等のタスク実行は npm/yarn/pnpm 等のランタイム固有ランナーより `mise run <task>` を優先する
  - どのタスクが定義されているか不明な場合は `mise tasks --all --json` で一覧を確認する
