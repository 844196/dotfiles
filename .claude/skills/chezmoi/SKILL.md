---
name: chezmoi
description: chezmoi 管理下の dotfiles リポジトリでソースを編集・新規作成するときの汎用知識。ファイル名プレフィックス (`dot_`/`exact_`/`private_`/`executable_`/`symlink_`/`empty_`/`remove_`/`run_*` 等) の意味と組み合わせ順序、`.tmpl` テンプレート、`.chezmoiscripts/` ライフサイクルスクリプト、`.chezmoiexternal.yaml` の使い方を扱う。`.chezmoi*` 系設定ファイルや `dot_*` / `run_*` プレフィックス付きファイルが並ぶリポジトリで作業しているとき、`chezmoi apply` / `diff` / `add` / `edit` の挙動やターゲット側削除の手順を確認したいときに必ず参照する。
---

# chezmoi スキル

chezmoi は「ソース ↔ ターゲットの双方向変換」を強い命名規約で実現するツール。エージェントが踏み外しがちな点を中心に、判断のよりどころをまとめる。プロジェクト固有の運用 (リポジトリの 3 層構造、独自タスクランナー、独自命名等) はこのスキルの対象外。プロジェクト固有の規範はリポジトリの `CLAUDE.md` / `.claude/rules/*.md` を参照する。

## 大前提: ソースを編集する、ターゲットを直接編集しない

chezmoi の作業は常に**ソース** (リポジトリ内のファイル) を編集して `chezmoi apply` で**ターゲット** (`~/` 配下) に反映する流れ。エージェントが `~/.zshrc` を直接編集すると、次回 apply で上書きされて変更が消える。

| 操作 | コマンド | 用途 |
|---|---|---|
| 差分確認 | `chezmoi diff` | ソース → ターゲットの反映差分をプレビュー |
| 反映 | `chezmoi apply` | ソースの内容をターゲットに書き出す |
| ソース編集 | `chezmoi edit <target>` | ターゲットパスを渡してソースを開く (パス変換を肩代わり) |
| 取り込み | `chezmoi add <target>` | ターゲットにある既存ファイルをソース管理下に取り込む |

`chezmoi add` は属性 (実行権限・パーミッション) を見て自動でプレフィックスを決めるが、意図しないプレフィックス (`executable_` や `private_`) が付くことがある。プロジェクトの命名規約と合わない場合があるので、結果はかならず確認する。「設定の意図」が分かっている場合は、`add` を使わず手動で `dot_config/<tool>/...` 等にコピーするほうが事故が少ない。

## `.chezmoiroot` (ソースルートの位置)

chezmoi は通常、**リポジトリ (= working tree) のトップ**をソースルートと見なし、その直下にある `dot_*` / `run_*` / `.chezmoiscripts/` / `.chezmoiexternal.yaml` などを解釈する。これを変えるのが `.chezmoiroot` ファイル。

リポジトリ直下に `.chezmoiroot` を置き、中身に**リポジトリ直下からの相対パス**を 1 行で書くと、その配下がソースルートとして扱われる。たとえば中身を `files` とした場合 (`<repo>/.chezmoiroot` の中身が `files` の 1 行):

- `~/.zshrc` の正体は `dot_zshrc` ではなく `files/dot_zshrc`
- `.chezmoiscripts/` は `files/.chezmoiscripts/` を見る
- `.chezmoiexternal.yaml` / `.chezmoiignore` / `.chezmoidata/` / `.chezmoitemplates/` / `.chezmoi.toml.tmpl` などの設定もすべて `files/` 配下を起点とする
- `chezmoi source-path` は `files/` の絶対パスを返す
- `chezmoi edit <target>` / `chezmoi add <target>` も `files/` 側を読み書きする

リポジトリ直下に chezmoi 管轄外のもの (CI 設定、README、自作ツールのソース、ビルド設定等) を共存させたいときに使う。dotfiles 専用ではない monorepo 的な構成と相性がいい。

`.chezmoiroot` がある状態でリポジトリ直下に `dot_*` ファイルを足しても**無視される** (apply に出てこない)。エージェントが「なぜ反映されないのか」とハマる典型ポイントなので、知らないリポジトリで作業を始めるときは最初に `.chezmoiroot` の有無を確認する。`chezmoi source-path` (引数なし) を実行すれば、ソースルートの絶対パスが返るので解決先を即座に確認できる。

## ファイル/ディレクトリ名プレフィックス

ソース側のファイル名・ディレクトリ名の**先頭**に付くプレフィックスで、ターゲットでの名前・属性・挙動を制御する。

| プレフィックス | 効果 | 例 |
|---|---|---|
| `dot_` | 先頭の `.` に変換 | `dot_zshrc` → `~/.zshrc` |
| `exact_` | (ディレクトリ専用) 中身を完全掌握。列挙されていないファイルは apply 時に削除 | `exact_dot_config/` |
| `external_` | (ディレクトリ専用) `.chezmoiexternal` で管理される印 | |
| `private_` | パーミッションを `0600` (所有者のみ読み書き)。ディレクトリにも付けて `0700` に | `private_dot_ssh/` |
| `readonly_` | パーミッションを `0444` (全員読み取り専用) | |
| `executable_` | (ファイル専用) 実行権限 `0755` を付与 | `executable_install.sh` |
| `symlink_` | symlink を作成。**ファイル内容**がリンク先パス (相対 or 絶対) | `symlink_dot_zshenv` (中身: `.zsh/.zshenv`) |
| `empty_` | (ファイル専用) 空ファイルを配置。chezmoi は通常空ファイルを無視するためこれが必要 | `empty_dot_hushlogin` |
| `remove_` | ターゲット側のファイル/ディレクトリを削除 | `remove_dot_bashrc` |
| `literal_` プレフィックス / `.literal` サフィックス | 出現位置以降の attribute 解析を停止し、ファイル名をリテラルとして扱う | `literal_executable_foo` → ターゲット名 `executable_foo` |
| `run_*` | (ファイル専用) `.chezmoiscripts/` 配下のライフサイクルスクリプト (詳細後述) | `run_after_10-foo.sh` |
| `create_` | (ファイル専用) ターゲットに既存があれば上書きしない (初回のみ作成) | `create_dot_gitconfig` |
| `modify_` | (ファイル専用) 実行可能スクリプトとして書く。apply 時にターゲットの現在の内容が stdin に流れ、stdout に書いた内容が新しいターゲットになる (ターゲットが存在しないときは stdin が空) | `modify_dot_zshrc` |
| `encrypted_` | age/gpg で暗号化されたファイル (`.age` / `.asc` サフィックス込みで運用) | `encrypted_private_dot_npmrc.age` |

### プレフィックスの組み合わせと順序

複数の attribute はターゲット種別ごとに**決められた順序**でしか書けない (chezmoi 公式の `source-state-attributes` リファレンスより)。

| ターゲット種別 | 順序 |
|---|---|
| 通常ファイル | `encrypted_` → `private_` → `readonly_` → `empty_` → `executable_` → `dot_` |
| `create_` ファイル | `create_` → `encrypted_` → `private_` → `readonly_` → `empty_` → `executable_` → `dot_` |
| `modify_` ファイル | `modify_` → `encrypted_` → `private_` → `readonly_` → `executable_` → `dot_` |
| ディレクトリ | `remove_` → `external_` → `exact_` → `private_` → `readonly_` → `dot_` |
| スクリプト | `run_` → (`once_` または `onchange_`) → (`before_` または `after_`) |
| symlink | `symlink_` → `dot_` |

`literal_` プレフィックスと `.literal` サフィックスは上記順序のどこにでも置けて、出現位置以降の解析を止める。

例:

- `dot_local/bin/executable_foo` → `~/.local/bin/foo` (実行可)
- `private_dot_ssh/private_config` → `~/.ssh/config` (ディレクトリも `0700`、ファイルも `0600`)
- `private_dot_zshrc` → `~/.zshrc` (`0600`)

順序の組み合わせに自信がないときは `chezmoi target-path <source>` でソース → ターゲットの変換結果を確認できる。

### `.tmpl` サフィックス

ファイル名末尾の `.tmpl` は前述プレフィックスとは別軸で、Go template として評価される印 (詳細は後述)。`.tmpl` を付けても付けなくてもターゲットのファイル名から `.tmpl` は落ちる。

## `exact_` を付けるか外すか

`exact_` は**ディレクトリ専用**の attribute で、付けると「この階層のファイル一覧をソースが完全掌握する」になる。ソースに無いファイルは apply 時に**削除される**。

判断基準:

- **付ける**: そのディレクトリの内容を chezmoi で完全に掌握したい場合。自分の設定だけが置かれることが確実 (= 他のプロセスが副次的にファイルを足さない) なディレクトリ。
- **外す**: 他のツール・プロセス・OS が動的にファイルを書き込むディレクトリ。

`exact_` を外すべき典型例:

- キャッシュ・state ディレクトリ (アプリが動的に書き込む)
- プラグインマネージャ・補完関数のインストール先
- パッケージマネージャやランタイムのプラグインディレクトリ
- systemd unit の symlink 置き場 (`systemctl enable` が symlink を置く)
- ツールが XDG を守らず `~/.config/<tool>/` 直下に状態を書くケース
- 外部リソース (`.chezmoiexternal.yaml`) で展開先になっているパスの**親ディレクトリ**

迷ったら付けない方が安全。`exact_` を付けると他ツールの生成物が apply 時に消える事故が起こり得る。

### 「掌握はしたいが一部は除外」のパターン

「外部ツールが書き込むが chezmoi 管理ぶんは掌握したい」場合は、`exact_` を付けつつ、その階層に `.chezmoiignore` を置いて**外部配置パスだけを除外**する組み合わせを使える。`.chezmoiignore` のパターンは glob で、`!` で再 include もできる。

## `.tmpl` テンプレートの用途

ファイル名末尾が `.tmpl` のファイルは Go template として評価される。新規ファイルはまずプレーンに書き、以下のいずれかが必要になったときだけ `.tmpl` 化する。

### (a) OS / アーキ / ホスト差異の吸収

```gotemplate
{{ if eq .chezmoi.os "darwin" -}}
# macOS 向け
{{ else if eq .chezmoi.os "linux" -}}
# Linux 向け
{{ end -}}
```

利用できるよく使う組み込みデータ:

| 変数 | 内容 |
|---|---|
| `.chezmoi.os` | `darwin` / `linux` / `windows` |
| `.chezmoi.arch` | `amd64` / `arm64` 等 |
| `.chezmoi.hostname` | ホスト名 |
| `.chezmoi.username` | 実行ユーザー名 |
| `.chezmoi.homeDir` | ホームディレクトリ絶対パス |
| `.chezmoi.sourceDir` | chezmoi ソースの絶対パス |
| `.chezmoi.kernel.osrelease` | Linux の `/etc/os-release` 由来情報 (WSL 検出等に使う) |

WSL2 と通常 Linux はどちらも `.chezmoi.os == "linux"` で同じ。区別するなら `.chezmoi.kernel.osrelease` を見る。

### (b) 環境依存値の埋め込み

ホストごとに変わる絶対パスや動的な値を埋める。`.chezmoi.sourceDir` (ソースの絶対パス)、`.chezmoi.homeDir` (ホーム) などが代表例。

カスタムデータは `.chezmoi.toml.tmpl` / `.chezmoi.yaml.tmpl` の `data:` で定義でき、テンプレートから `.<key>` で参照できる。プロンプト化したい値は `promptString` / `promptBool` 等を使う。

### (c) `.chezmoitemplates/` の共通パーツ include

`.chezmoitemplates/<name>` に置いたファイルは、テンプレートから `{{ template "<name>" . }}` で include できる。`.` を渡すと現在のスコープのデータをそのまま見せる。

ターゲットには出ない (ターゲット非対応のテンプレート専用ディレクトリ)。

## `.chezmoiscripts/` のライフサイクルスクリプト

ライフサイクルスクリプトの正体は `run_*` プレフィックス付きのソースファイル。これがあると、ターゲットには配置されず apply 時に**実行**される。ソースのどこに置いても動作するが、慣習として `.chezmoiscripts/` ディレクトリに集めて運用する (このディレクトリ自体もターゲットには出ない)。

### 命名規則

```
run_[onchange_|once_]<after|before>_<NN>-<description>.sh[.tmpl]
```

| プレフィックス | 実行タイミング |
|---|---|
| `run_before_NN-*` | `chezmoi apply` 前、毎回実行 |
| `run_after_NN-*` | `chezmoi apply` 後、毎回実行 |
| `run_onchange_before_NN-*` | スクリプト内容変更時のみ、apply 前に実行 |
| `run_onchange_after_NN-*` | スクリプト内容変更時のみ、apply 後に実行 |
| `run_once_before_NN-*` | 一度だけ実行 (apply 前) |
| `run_once_after_NN-*` | 一度だけ実行 (apply 後) |

`run_onchange_*` の「変更検出」はスクリプト内容のハッシュで判定される。テンプレート出力が同じならハッシュも同じになるので再実行されない。

スクリプト本体が変わらないが**外部データの変更に連動して再実行させたい**ときは、データの sha256 をコメントで埋めると、データが変わるたびにスクリプト内容のハッシュも変わって再実行される (公式の典型例):

```sh
#!/bin/bash
# dconf.ini hash: {{ include "dconf.ini" | sha256sum }}
dconf load / < {{ joinPath .chezmoi.sourceDir "dconf.ini" | quote }}
```

参照しているデータファイル自体はターゲットに配置したくないことが多いので、`.chezmoiignore` に登録して deploy から外すのが定石。

### 番号 `NN` の役割

番号は実行順序の指定。chezmoi はファイル名 (lexicographic) 順に実行する。依存関係に応じて決める。飛び番は許容され、後から間にスクリプトを挿入する余地を残せる。

### `.tmpl` サフィックスとの組み合わせ

`run_after_10-foo.sh.tmpl` のようにテンプレート化できる。テンプレート評価結果が空文字列だとスクリプトはスキップされる (条件付き実行に使える)。

### スクリプトの書き方

- shebang を書く (`#!/usr/bin/env bash` / `#!/bin/sh` 等)
- 失敗時に止めるなら `set -euo pipefail` を冒頭に置く
- chezmoi が exit code を見るので、無視したいエラーは個別に `|| true` する

## `.chezmoiexternal.yaml` (外部リソース)

外部 URL から取得して `~/` に配置する仕組み。GitHub の zsh プラグイン、テーマ、単一バイナリのインストーラ等に使う。

### `type` の選択

| `type` | 用途 | 主なオプション |
|---|---|---|
| `file` | 単一ファイルを保存 | `executable: true` で実行権限を付与 |
| `archive` | tar.gz / zip を展開 | `exact: true` で展開先ディレクトリを完全掌握、`stripComponents: <N>` でアーカイブ先頭の包みを N 段剥がす、`include` / `exclude` で展開対象を glob で絞る、`format` でアーカイブ形式を明示 |
| `archive-file` | アーカイブ内の特定ファイルだけ取り出す | `path: <アーカイブ内パス>`、`executable: true` |
| `git-repo` | git clone した状態を維持する | clone / pull に渡す引数を細かく指定可 |

すべての type に共通: `url` (必須、単一の URL)、`urls` (任意、フォールバック URL のリスト。`url` が失敗したら順に試す)、`refreshPeriod` (再取得間隔、後述)、`encrypted` (暗号化)、`checksum.sha256` / `sha384` / `sha512` (整合性検証)。

### バージョン固定

URL に commit hash か tag を埋めて固定するのが基本。pin している意図 (再現性確保) を尊重し、エージェントは指示されない限り URL を書き換えない。

```yaml
".zsh/plugins/zsh-syntax-highlighting":
  type: archive
  url: "https://github.com/zsh-users/zsh-syntax-highlighting/archive/<commit-or-tag>.tar.gz"
  exact: true
  stripComponents: 1
```

### 衝突回避

`.chezmoiexternal.yaml` で展開先になっているパスと同じ場所を、ソース側で `exact_` 付きディレクトリとして管理しないこと。external 展開と source apply で書き合いになる。**親ディレクトリ**は `exact_` を外し、子の中身を external に任せる。

### `refreshPeriod`

外部リソースを再取得する間隔。**デフォルトは `0` = 一度取得したら再取得しない**。手動で更新したいときは `chezmoi apply -R` (`--refresh-externals`) で強制再取得する。コミットハッシュ固定であれば `0` のままが自然。タグ移動を追従させたいときだけ `168h` 等の値を入れる。

## ターゲット側からの削除

ソースから単純にファイルを消しても、親ディレクトリが `exact_` でない限り、apply ではターゲットに伝播しない (= 何もしない)。明示的にターゲットから消すには:

1. ソースルート直下に `.chezmoiremove` を一時作成 (ターゲットの相対パスを 1 行ずつ列挙)
2. `chezmoi apply` を走らせて削除を反映
3. `.chezmoiremove` を削除 (コミットしない)

`remove_` プレフィックス付きソースファイルでも個別ファイルの削除は表現できる (こちらはコミット履歴に残る)。

## ターゲット側のリネームや移動

`exact_` 配下なら、ソース側で改名するだけで apply 時に旧ファイルが削除される。`exact_` でないなら旧ファイルは残るので、`.chezmoiremove` で明示削除するか `remove_` ファイルを置く。

## `.chezmoiignore`

apply で配置しないソースファイルを glob で列挙する。`!` で再 include。`.tmpl` 化すれば OS ごとに ignore 対象を切り替えられる (例: macOS でだけ Linux 用の `.service` ファイルを ignore)。

## `.chezmoidata/` (定数データ)

`.chezmoidata/<name>.{toml,yaml,json}` に置いたデータはテンプレート内から `.<top-key>...` で参照できる。`.chezmoi.toml.tmpl` の `data:` と機能は近いが、こちらは複数ファイルに分割でき、ホスト共通の定数を入れるのに向く (config はホスト固有値、`.chezmoidata/` は共通定数、と切り分けるのが定石)。

## グローバルコマンドラインフラグ

多くの chezmoi コマンドで共通して使える便利なフラグ。

| フラグ | 短縮形 | 効果 |
|---|---|---|
| `--dry-run` | `-n` | 実際のファイルシステム変更を行わない。何が起きるかを事前確認 |
| `--verbose` | `-v` | 詳細出力。実行されるアクションを表示 |

組み合わせ例:

- `chezmoi apply -n` — 反映のドライラン
- `chezmoi apply -v` — 反映時に詳細ログ
- `chezmoi apply -nv` — ドライラン + 詳細ログ (実行されるスクリプトの内容も表示)
- `chezmoi diff -v` — 差分表示 + 詳細ログ

`--dry-run` と `--verbose` は `apply`, `add`, `remove`, `update` など変更を伴う多くのコマンドで使える。

## デバッグの定石

- `chezmoi diff` でまず差分プレビュー
- `chezmoi apply -v` で詳細ログ
- `chezmoi apply --dry-run` で実行せず確認
- `chezmoi execute-template < file` でテンプレートだけ評価
- `chezmoi data` で利用可能なテンプレートデータを表示
- `chezmoi target-path <source>` でソース → ターゲットの変換結果を確認
- `chezmoi managed` で chezmoi 管理下のターゲットを列挙
- `chezmoi doctor` で環境診断

`apply` が想定外の動きをしたら、まず `chezmoi diff` と `--dry-run` でステップを切り分ける。
