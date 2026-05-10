---
paths:
  - "**/*.md"
---

# ドキュメントからリポジトリ内のファイル・ディレクトリについて言及・参照する際のルール

リポジトリ内のファイル・ディレクトリについて言及・参照する際は、相対パスのリンクを使用する。これによって移動や名前変更によるリンク切れを `lychee` で検出できるようになる。

**OK:**
```markdown
コミットタイプは [`convco` 設定ファイル](.versionrc) を参照のこと。
```

**NG:**
```markdown
コミットタイプは `.versionrc` を参照のこと。
```

リンクテキスト (`[` と `]` で囲まれた部分) は、"その時点での個別具体的な名前" ではなく一般的な名前もしくは抽象的な表現を使用する。これにより、将来のリファクタリングや構成の変更に対して柔軟性が増し、無駄な追従対応を減らすことができる。

**OK:**
```markdown
`chezmoi` の補完関数は [generate-chezmoi-completion](files/.chezmoiscripts/run_onchange_after_11b-generate-chezmoi-completion.sh.tmpl) によって `chezmoi apply` 時に生成される。
```

**NG:**
```markdown
`chezmoi` の補完関数は [`run_onchange_after_11b-generate-chezmoi-completion.sh.tmpl`](files/.chezmoiscripts/run_onchange_after_11b-generate-chezmoi-completion.sh.tmpl) によって `chezmoi apply` 時に生成される。
```

ただし、TOC としての責務担うリンク (e.g. コードベース構成を示すためのリンク) のリンクテキストは、実際のファイル・ディレクトリ名をリンクテキストにすること。これは、ファイル・ディレクトリ名自体が重要な情報であるため。

**例:**
```markdown
## 構成

- [`files/`](files/CLAUDE.md) - Chezmoi のソースルート ([`.chezmoiroot`](.chezmoiroot) によって設定)。

  このディレクトリ以下のファイルは `chezmoi apply` によってターゲット (`~/`) に展開されます。

- [`packages/tool-*/`](.claude/rules/diy-tools.md) - 自作ツールのソースコード。

  「シェルスクリプトで実装すると複雑になるので、TypeScript などで書いてビルドして配置したいが、独立したリポジトリにするほどではない自作ツール」のソースコードを配置します。`chezmoi apply` 時に chezmoiscripts によってビルドされ、ホームディレクトリ以下に配置されます。
```

## 同一ファイルへの参照が複数ある場合

ドキュメント内で同一ファイルへの参照が複数ある場合は、レファレンスリンクを使用して、リンク先を一元管理する。これにより、ロード時のトークン数の削減と、将来のリファクタリングに対する柔軟性が向上する。

**例:**
```markdown
各ツールのバージョンは [chezmoidata] 内の `$.versions.<tool-name>` に記述する。

<!-- snip -->

`run_onchange_*.tmpl` から [chezmoidata] にある各ツールのバージョンは `{{ .versions.<tool-name> }}` で参照できる。

<!-- snip -->

[chezmoidata]: ../../files/.chezmoidata.json
```

## ディレクトリを参照する場合

単にあるディレクトリについて言及・参照する場合や、"ディレクトリによって境界づけられたモジュール" について言及・参照する場合は、次の優先順位に従う:

1. 対象のディレクトリに `CLAUDE.md` が存在する場合は、そのファイルへのリンクとする。

   ```markdown
   [`git-add-A`](packages/git-add-A/CLAUDE.md)
   ```

2. 対象のディレクトリがターゲットとなる `.claude/rules/*.md` が存在する場合は、そのファイルへのリンクとする。これは、Nested `CLAUDE.md` を配置することがふさわしくない・技術的に配置することが出来ない場合に適用される。

   ```markdown
   [chezmoiscripts](../.claude/rules/chezmoiscripts.md)
   ```

   ```markdown
   [自作ツール](../.claude/rules/diy-tools.md)
   ```

3. それ以外の場合は、ディレクトリへのリンクとする。

   ```markdown
   [`~/.cache/`](files/dot_cache/)
   ```
