---
paths:
  - files/**
---

# chezmoi ソース編集の基本

`files/` は chezmoi のソースルート (`.chezmoiroot` で `files` を指定)。`~/` を直接編集せず、ここを編集して `chezmoi apply` で反映する流れに従う。リポジトリ直下に `dot_*` を置いても**無視される** (apply に出てこない) ので注意。

`.chezmoiscripts/` 自体の運用方針は [`chezmoiscripts.md`](./chezmoiscripts.md) を参照。

## ファイル名プレフィックスの順序

複数 attribute はターゲット種別ごとに**決められた順序**でしか書けない。順序を間違えると chezmoi がパースに失敗するか、意図しないファイル名のまま配置される。

| 種別 | 順序 |
|---|---|
| 通常ファイル | `encrypted_` → `private_` → `readonly_` → `empty_` → `executable_` → `dot_` |
| `create_` ファイル | `create_` → `encrypted_` → `private_` → `readonly_` → `empty_` → `executable_` → `dot_` |
| `modify_` ファイル | `modify_` → `encrypted_` → `private_` → `readonly_` → `executable_` → `dot_` |
| ディレクトリ | `remove_` → `external_` → `exact_` → `private_` → `readonly_` → `dot_` |
| スクリプト | `run_` → (`once_` または `onchange_`) → (`before_` または `after_`) |
| symlink | `symlink_` → `dot_` |

迷ったら `chezmoi target-path <source>` で変換結果を確認する。

主なプレフィックスの効果:

| プレフィックス | 効果 |
|---|---|
| `dot_` | 先頭の `.` に変換 |
| `exact_` | (ディレクトリ) 中身を完全掌握、列挙されてないファイルは apply 時に削除 |
| `private_` | パーミッション `0600` (ファイル) / `0700` (ディレクトリ) |
| `executable_` | (ファイル) 実行権限 `0755` |
| `symlink_` | symlink を作成、ファイル内容がリンク先パス (相対 or 絶対) |
| `empty_` | (ファイル) 空ファイルを配置 (chezmoi は通常空ファイルを無視するためこれが必要) |
| `remove_` | ターゲットの該当パスを削除 |
| `encrypted_` | age/gpg で暗号化 (`.age` / `.asc` サフィックス込みで運用) |
| `create_` | (ファイル) ターゲットに既存があれば上書きしない (初回のみ作成) |
| `modify_` | (ファイル) 実行可能スクリプト、stdin にターゲット現状、stdout が新しいターゲット |

## `exact_` を付けるか外すか

ディレクトリ専用。付けると「ソースに無いファイルは apply 時に削除」になる。

- **付ける**: そのディレクトリを chezmoi で完全掌握したい場合 (動的生成なし、自分の設定だけが置かれることが確実)
- **外す**: 他のツール・プロセス・OS が動的に書き込むディレクトリ (キャッシュ、プラグインマネージャ、systemd unit symlink 置き場、`.chezmoiexternal.yaml` で展開先になっているパスの**親**)

迷ったら付けない方が安全。`exact_` を付けたディレクトリの中で chezmoi 管轄外のファイルを許したい場合は `exact_` のまま `.chezmoiignore` で個別除外する (`!` で再 include も可)。

## `.tmpl` テンプレート

ファイル名末尾が `.tmpl` だと Go template として評価される。プレーンに書いて済むならテンプレート化しない。以下のいずれかが必要になったときだけ `.tmpl` 化する:

- **OS / arch / ホスト差異の吸収**: `.chezmoi.os` (`darwin`/`linux`/`windows`)、`.chezmoi.arch`、`.chezmoi.kernel.osrelease` (WSL2 と素の Linux はどちらも `.chezmoi.os == "linux"` なので区別はこちらで)
- **環境依存値の埋め込み**: `.chezmoi.sourceDir`、`.chezmoi.homeDir`、`.chezmoi.username`
- **`.chezmoidata/` の参照**: `.chezmoidata/<name>.{toml,yaml,json}` に置いた値はテンプレートから `.<top-key>...` で参照できる。ホスト共通の定数置き場として使う
- **`.chezmoitemplates/` の include**: `{{ template "<name>" . }}` で共通パーツを差し込む。`.` で現在のスコープを渡す

## `.chezmoiexternal.yaml`

外部 URL から取得して配置する仕組み。`type` は `file` / `archive` / `archive-file` / `git-repo` から選ぶ。

バージョンは commit hash か tag を URL に埋めて固定する。指示されない限り URL は書き換えない (再現性確保のため pin している)。

`refreshPeriod` のデフォルトは `0` (一度取得したら再取得しない)。手動更新は `chezmoi apply -R`。コミットハッシュ固定なら `0` のままが自然。

**衝突回避**: external の展開先と同じパスを `exact_` 付きディレクトリで同時管理しない (書き合いになる)。親ディレクトリは `exact_` を外し、子の中身を external に任せる。

## ターゲット側からの削除

ソースから単純にファイルを消しても、親ディレクトリが `exact_` でない限り apply ではターゲットに伝播しない。明示削除は:

1. ソースルート (`files/`) 直下に `.chezmoiremove` を一時作成 (ターゲットの相対パスを 1 行ずつ列挙)
2. `chezmoi apply` で削除を反映
3. `.chezmoiremove` を削除 (コミットしない)

個別ファイル単位なら `remove_` プレフィックス付きソースファイルでも表現できる (こちらは履歴に残る)。

## デバッグ

- `chezmoi diff` — ソース → ターゲットの差分プレビュー
- `chezmoi apply -nv` — ドライラン + 詳細ログ (実行されるスクリプトの内容も表示)
- `chezmoi target-path <source>` — ソース → ターゲットの変換結果
- `chezmoi execute-template < file` — テンプレート単体評価
- `chezmoi data` — 利用可能なテンプレートデータを表示
- `chezmoi managed` — 管理下ターゲット列挙
- `chezmoi source-path` — ソースルートの絶対パス
