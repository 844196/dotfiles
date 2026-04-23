---
name: using-mise-tasks
description: |
  mise のタスク機能（TOML タスク、ファイルタスク、monorepo タスク）に関するガイドライン。
  mise.toml が存在するプロジェクトでタスクの実行・定義・変更を行う際に参照する。

  以下の状況でこのスキルを参照する:
  - `mise run` でタスクを実行する
  - `mise.toml` の `[tasks]` セクションを読み書きする
  - ファイルベースタスク（`.mise/tasks/` 等）を作成・編集する
  - monorepo 構成のプロジェクトで `//` プレフィックス付きタスクを扱う
---

# Using mise Tasks

mise のタスク機能を正しく使うためのガイドライン。
このスキルはモデルの学習データでカバーが薄い領域を補完する目的で作成されている。

## 1. タスクの2つの定義方式

mise のタスクには **TOML タスク** と **ファイルタスク** の2種類がある。

### TOML タスク（mise.toml 内に定義）

シンプルなコマンドや、依存関係・env・sources/outputs の設定が必要なタスクに向く。

```toml
# 簡潔な形式
[tasks]
build = "cargo build"
test = "cargo test"

# 詳細な形式
[tasks.deploy]
run = "deploy.sh"
depends = ["build", "test"]
env = { NODE_ENV = "production" }
sources = ["src/**/*.ts"]
outputs = ["dist/**"]
```

### ファイルタスク（スクリプトファイルとして定義）

複雑なロジックを含むタスクに向く。エディタの構文ハイライトや lint が効く。

**配置ディレクトリ**（いずれか）:
- `mise-tasks/`
- `.mise-tasks/`
- `mise/tasks/`
- `.mise/tasks/`
- `.config/mise/tasks/`

**ファイルは実行権限が必須** (`chmod +x`)。

```bash
#!/usr/bin/env bash
#MISE description="Run e2e tests"
#MISE depends=["build"]
#MISE sources=["src/**/*.ts", "tests/**/*.ts"]
#MISE dir="{{cwd}}"

set -euo pipefail
# ここに複雑なスクリプトを書く
```

**ディレクトリによるタスクのグルーピング**:
```
mise-tasks/
  build              -> タスク名: "build"
  test/
    _default          -> タスク名: "test"
    integration       -> タスク名: "test:integration"
    units             -> タスク名: "test:units"
```

### 使い分けの基準

| 使う場面 | 選ぶべき方式 |
|---|---|
| ワンライナー〜数行のコマンド | TOML タスク |
| 依存関係・env・sources/outputs の設定 | TOML タスク |
| 10行を超えるスクリプト | ファイルタスク |
| シェル以外の言語（Node.js, Python 等）で書くタスク | ファイルタスク |
| エディタの構文ハイライトや lint を効かせたい | ファイルタスク |

10行を超えるスクリプトはファイルタスクとして定義する。TOML タスクから外部スクリプトを呼び出すのではなく、スクリプト自体をファイルタスクにする。

## 2. タスクの実行

```bash
mise run <task>                   # 基本形
mise run <task> <args...>         # 引数・フラグはそのまま後ろに続ける（Smart Flag Routing）
mise run build ::: test           # 複数タスクを別々の引数で実行（::: 区切り）
```

### 引数・フラグの渡し方

mise は Smart Flag Routing を採用していて、引数・フラグは `--` を挟まずに直接渡せる:

```bash
mise run build --release          # --release はタスクへルーティング
mise run deploy prod --verbose    # 位置引数・フラグそのまま
```

`--` が必要なのは、mise 予約フラグ (`-q`, `-v`, `-h`, `--help`) をタスク側に渡したい時だけ:

```bash
mise run foo -- --help            # タスクの --help を呼ぶ（mise の help ではなく）
mise run foo -- -q arg1           # タスクに -q を渡す
```

`--` の本来の用途は escape hatch。通常のタスク引数には不要。

### タスクの情報取得

タスクの情報を取得するときは `--json` を付ける。JSON 出力には `description`、`run`（実行コマンド）、`depends`、`usage`（引数定義）等の構造化情報が含まれる。

```bash
mise tasks --json //packages/app:build  # 特定タスクの詳細（usage_spec を含む）
mise tasks --all --json                 # monorepo 全体のタスク一覧
```

- タスクを実行する前に引数を確認するには `mise tasks --json <task-name>` で `usage_spec` を確認する
- CLAUDE.md に書かれていないタスクの存在や使い方を調べるには `mise tasks --all --json` を実行する

注意: `mise tasks --json //packages/<name>` はパッケージ内の全タスクを列挙しない（1件目しか返さない）。パッケージ内のタスク一覧は `mise tasks --all --json` の出力を `name` でフィルタする。

## 3. Monorepo タスク

monorepo 機能が有効なプロジェクトでは、サブディレクトリのタスクがパスで名前空間化される。

### 有効化

```toml
# ルートの mise.toml
experimental_monorepo_root = true

[monorepo]
config_roots = [
  "packages/frontend",
  "packages/backend",
  "services/*",
]
```

### タスクパス構文

| 構文 | 意味 | 例 |
|---|---|---|
| `//path:task` | monorepo ルートからの絶対パス | `mise run //packages/app:build` |
| `:task` | 現在の config_root のタスク | `mise run :build` |
| `task` | `:task` と同じ（互換性のため） | `mise run build` |

### `//` プレフィックスの重要なポイント

`//` は **monorepo ルートからの絶対パス** を意味する。CWD がどこであっても同じタスクを指す。`cd` は不要。

```bash
mise run //packages/app:build
```

### ワイルドカード

```bash
mise run '//...:test'                 # 全プロジェクトの test タスク
mise run '//packages/...:build'       # packages/ 以下全ての build タスク
mise run '//packages/frontend:*'      # frontend の全タスク
mise run '//packages/...:*'           # packages/ 以下全プロジェクトの全タスク
```

- `...` はディレクトリの任意の深さにマッチ
- `*` はタスク名のワイルドカード
- パスワイルドカード `...` とタスクワイルドカード `*` は組み合わせられる。「複数プロジェクトで lint/check/test を一発で」といった用途では `//packages/...:*` が最短

### プロジェクト間の依存

```toml
# packages/app/mise.toml
[tasks.build]
depends = ["//packages/lib:build"]    # 他プロジェクトのタスクに依存
depends = [":lint"]                   # 自プロジェクトのタスク（: プレフィックス推奨）
```

## 4. 主要な設定オプション

| オプション | 用途 |
|---|---|
| `run` | 実行するコマンド（文字列 or 配列） |
| `depends` | 事前に実行するタスク |
| `depends_post` | 事後に実行するタスク |
| `env` | タスク固有の環境変数 |
| `dir` | 作業ディレクトリ（デフォルト: `{{ config_root }}`） |
| `sources` | 入力ファイル（glob）。変更検知に使用 |
| `outputs` | 出力ファイル（glob）。変更検知に使用 |
| `tools` | タスク固有のツールバージョン |
| `usage` | 引数・フラグの定義（TOML タスクのみ） |
| `raw` | stdin を直接接続（対話的タスク向け） |

## 5. 環境変数

mise はタスク実行時に以下の環境変数を設定する:

| 変数 | 内容 |
|---|---|
| `MISE_ORIGINAL_CWD` | `mise run` を実行した元のディレクトリ |
| `MISE_CONFIG_ROOT` | `mise.toml` があるディレクトリ |
| `MISE_PROJECT_ROOT` | プロジェクトルート |
| `MISE_TASK_NAME` | 実行中のタスク名 |

## 6. 引数の定義

### TOML タスクでの引数定義（`usage` フィールド）

```toml
[tasks.deploy]
usage = '''
arg "<environment>" help="Target environment" {
  choices "dev" "staging" "prod"
}
flag "-v --verbose" help="Enable verbose output"
'''
run = 'deploy --env ${usage_environment}'
```

### ファイルタスクでの引数定義（`#USAGE` ヘッダ）

```bash
#!/usr/bin/env bash
#USAGE arg "<environment>" help="Target environment" { choices "dev" "staging" "prod" }
#USAGE flag "-v --verbose" help="Enable verbose output"

deploy --env "$usage_environment"
```

引数は `$usage_<name>` 環境変数として参照できる。

## mise 公式ドキュメント

- [Task Overview](https://mise.jdx.dev/tasks/)
- [Task Architecture](https://mise.jdx.dev/tasks/architecture.html)
- [Running Tasks](https://mise.jdx.dev/tasks/running-tasks.html)
- [Toml Tasks](https://mise.jdx.dev/tasks/toml-tasks.html)
- [File Tasks](https://mise.jdx.dev/tasks/file-tasks.html)
- [Task Arguments](https://mise.jdx.dev/tasks/task-arguments.html)
- [Task Configuration](https://mise.jdx.dev/tasks/task-configuration.html)
- [Task Templates](https://mise.jdx.dev/tasks/templates.html)
- [Monorepo Tasks](https://mise.jdx.dev/tasks/monorepo.html)
