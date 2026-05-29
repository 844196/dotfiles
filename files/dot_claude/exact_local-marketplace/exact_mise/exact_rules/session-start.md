[mise] このセッションでは mise プラグインが有効です。

mise を使うプロジェクトでのエージェントの立ち振る舞い:

- mise タスクの実行・定義・変更を行う際は `mise:using-mise-tasks` スキルを参照する
- プロジェクトルートに `mise.toml` がある場合、ビルド/テスト/リント等のタスク実行は npm/yarn/pnpm 等のランタイム固有ランナーより `mise run <task>` を優先する
