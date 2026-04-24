# chezmoi レイアウトの詳細

リポジトリの構造と、`files/` 以下で使われる chezmoi のしくみをまとめます。基本的な運用ルールは `CLAUDE.md` と `.claude/rules/chezmoi-source-editing.md` を参照してください。

## 3 層構造

| 層 | パス | 役割 |
|---|---|---|
| 1. chezmoi ソース | `files/` | `chezmoi apply` で `~/` に反映される設定ファイル群 |
| 2. 自作ツール | `packages/` | ビルドされて `~/` 配下に配置される自作ツールのソースコード |
| 3. プロジェクトメタ | リポジトリ直下の各種ファイル | リポジトリ運用のためのツールチェーン (mise, lefthook, convco 等) |

### `packages/` のビルドと配置

各 `packages/<tool-name>/mise.toml` に `build` タスクと `install` タスクを定義します。`install` は `build` に依存し、ビルド成果物を `~/.844196/bin` や `~/.844196/libexec` へ配置します。

`chezmoi apply` 後に `files/.chezmoiscripts/run_after_09-install-dotfiles-packages.sh.tmpl` がリポジトリルートで `mise run //packages/...:install` を呼び出し、全パッケージを配置します。

## chezmoi プレフィックス早見

ファイル名とディレクトリ名の先頭に付くプレフィックスで chezmoi の挙動を制御します。

| プレフィックス | 意味 |
|---|---|
| `dot_` | ファイル名先頭の `.` に置換 (例: `dot_zshrc` → `~/.zshrc`) |
| `exact_` | ディレクトリ内容を完全掌握 (列挙されていないファイルは apply 時に削除) |
| `private_` | パーミッションを `0600` にする |
| `symlink_` | ターゲットに symlink を作成。ファイル内容がリンク先パス |
| `empty_` | 空ファイルを配置 (chezmoi は通常、空ファイルを無視するため) |
| `remove_` | ターゲットのファイルを削除 |
| `literal_` | 先頭の attribute 解釈を抑止 (ファイル名をそのまま配置) |
| `executable_` | 実行権限 (`0755`) を付与 |
| `run_*` | ライフサイクルスクリプト (後述) |

### `exact_` を付けるか外すか

- **付ける**: そのディレクトリの内容を chezmoi で完全に掌握したい場合 (自分の設定だけが置かれることが確実なディレクトリ)
- **外す**: 他のプロセスやツールが副次的にファイルを動的に追加するディレクトリ

`exact_` を外す実例と理由:

- `dot_cache/`, `dot_local/state/*` — キャッシュ / state (動的に書き込まれる)
- `dot_local/share/{mise,navi,zsh}/{plugins,cheats,vendor-completions}` — プラグインや補完関数が動的に追加される
- `dot_docker/cli-plugins` — docker が plugin を自動追加
- `dot_config/systemd/user` — `systemctl enable` が unit の symlink を置く
- `dot_claude/`, `dot_claude/skills/` — Claude Code が `projects/` や `todos/` など動的生成物を置く / スキルが追加される
- `.chezmoiexternal.yaml` で展開先になっているパスの親ディレクトリ

迷ったら付けない方が安全です。`exact_` を付けると他ツールの生成物が apply 時に消える事故が起こり得ます。

XDG を守らず `~/.config/<tool>/` に状態を書き込むツールがある点にも注意してください。

### その他プレフィックスの運用

- **`private_`**: このリポジトリでの使用は macOS の LaunchAgent plist 1 件のみ。`launchd` が要求する権限要件を満たすために付けています。一般的な用途では使いません。
- **`symlink_`**: XDG 非準拠なパスを要求するツールを XDG 準拠の実体ファイルにリダイレクトしたいときに使います。実例: `symlink_dot_zshenv` → 中身 `.config/zsh/.zshenv` で、`~/.zshenv` を `~/.config/zsh/.zshenv` の symlink にしています。
- **`empty_`**: 存在自体に意味があるフラグファイルを置くときに使います。実例: `empty_dot_hushlogin` で login 時のメッセージを抑制しています。
- **`remove_`**: ディストリデフォルトで `~/` に置かれる不要ファイル (`.bashrc`, `.bash_history`, `.bash_logout`, `.motd_shown`) を削除しています。

## テンプレート (`.tmpl`) の 3 用途

ファイル名の末尾が `.tmpl` のファイルは Go template として評価されます。新規ファイルはプレーンに書き、以下のいずれかが必要になったときだけ `.tmpl` 化します。

### (a) OS 差異の吸収

```gotemplate
{{ if eq .chezmoi.os "darwin" -}}
# macOS 向け
{{ else -}}
# Linux 向け
{{ end -}}
```

実例: `files/dot_claude/exact_hooks/executable_notify.sh.tmpl` が macOS (`osascript`) と Windows (`powershell.exe` via WSL2) で通知コマンドを切り替えています。

WSL2 と devcontainer を区別する必要は現状ありません (どちらも `.chezmoi.os == "linux"`)。

### (b) 環境依存値の埋め込み

`{{ .chezmoi.sourceDir }}` や `{{ .dotfilesDir }}` など、ホストごとに変わる絶対パスを埋めます。

実例: `files/.chezmoiscripts/run_after_09-install-dotfiles-packages.sh.tmpl` が `{{.dotfilesDir}}` を使ってリポジトリの絶対パスを埋め込んでいます。

`.dotfilesDir` は `files/.chezmoi.yaml.tmpl` で独自に定義されたカスタムデータです。

### (c) `.chezmoitemplates/` の共通パーツ include

`files/.chezmoitemplates/` に共通パーツを置き、`{{ template "<filename>" }}` で include します。

実例: `files/dot_claude/skills/exact_commit/SKILL.md.tmpl` が `.chezmoitemplates/commit-skill-steps.md` を include。

この用途は最近追加されたばかりで運用方針は未確定です。エージェントは既存の include 構文を壊さないように扱い、新規に共通パーツを切り出すかどうかの判断はユーザーに任せてください。

## `.chezmoiscripts/` のライフサイクルスクリプト

### 命名規則

```
run_[onchange_]<after|before>_<NN>-<description>.sh[.tmpl]
```

| プレフィックス | 実行タイミング |
|---|---|
| `run_after_NN-*` | `chezmoi apply` 後、毎回実行 |
| `run_before_NN-*` | `chezmoi apply` 前、毎回実行 |
| `run_onchange_after_NN-*` | 内容変更時のみ実行 (apply 後) |

`run_once_*` はこのリポジトリでは使いません。再実行が必要な処理は `run_onchange_*` で表現し、初回限定の処理は `install.sh` に置きます。

### 用途

- **`run_after_NN-*`**: 「chezmoi がなかったら `.zshrc` に書いていたであろう処理」を切り出して、シェル起動時の負荷を下げるためのもの。`zsh compile`、`bat cache` 再生成、`systemctl daemon-reload` など
  - `run_after_08-setup-mise.sh` は `mise install` / `mise upgrade` を実行する関係で、mise が GitHub API を大量に呼びます。apply 時は `GITHUB_TOKEN` が事実上必須で、リポジトリルートの `mise run //:apply` タスクがラッパーとして `gh auth token` から埋めます (生の `chezmoi apply` は `.claude/settings.json` で `deny` 済み)
- **`run_before_NN-*`**: apply 前に管理対象ファイル (plist 等) を使っているツールを一時停止する用途。実例: `run_before_01-stop-chroma.sh`
- **`run_onchange_after_NN-*`**: 重いインストール処理。実例: `run_onchange_after_01-install-mise.sh` (mise 本体)、`run_onchange_after_12-apm-install.sh.tmpl` (apm パッケージ)

### 番号

番号は実行順序を表し、依存関係に応じて決めます (例: `00-systemd-daemon-reload` → `02-rebuild-bat-cache` → `11-start-chroma`)。

飛び番は許容されます。現状は後から間にスクリプトを挿入しやすいように隙間を残しています。

## `.chezmoiexternal.yaml` (外部リソース)

`files/.chezmoiexternal.yaml` に列挙したパスを外部 URL から取得して `~/` に配置します。

### 使いどころ (他に手段がない場合のみ)

- **zsh プラグイン** (`.local/share/zsh/plugins/*`): プラグインマネージャを使わずコミットハッシュ固定で取り込む
- **zsh 補完関数 / bat テーマ**: 単一ファイルで、mise や apm 経由で取得する手段がないもの
- **mise 本体のインストーラ**: curl と wget のどちらが入っているか不明な環境で、ダウンロードを chezmoi に任せたい
- **nvim lazy.nvim**: nvim のプラグインマネージャそのもの (これ自体を何らかの方法で置いておかないとプラグイン管理が始まらない)

### エントリの書き分け

| `type` | 用途 | 実例のオプション |
|---|---|---|
| `file` | 単一ファイルをダウンロード | `executable: true` で実行権限、`refreshPeriod: 168h` で更新チェック頻度 |
| `archive` | tar.gz を展開 | `exact: true` で展開先を完全掌握、`stripComponents: 1` で GitHub archive の先頭ディレクトリを剥がす |

バージョン固定は以下のパターンで行います:

- GitHub 上の zsh プラグイン: コミットハッシュ固定 (タグが付かないリポジトリがあるため)
- その他のツール: タグ固定 (例: `refs/tags/v4.11.0`)

### 衝突回避

external 管理下のパス (例: `.local/share/zsh/plugins/*`) を `files/dot_local/share/zsh/plugins/` 配下に直接置かないでください。親ディレクトリは `exact_` なしで残しておき、中身は external 展開に任せます。

## 参考

- 全体像と編集権限マトリクス: `CLAUDE.md`
- 編集時の規範: `.claude/rules/chezmoi-source-editing.md`
- `packages/` の詳細: `packages/CLAUDE.md`
