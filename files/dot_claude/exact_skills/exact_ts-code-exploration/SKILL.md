---
name: ts-code-exploration
description: TypeScriptプロジェクトにおけるコード探索のベストプラクティス。LSPツールを優先的に使用し、型解決に基づく正確な結果を得る。
---

# TypeScriptプロジェクトにおけるコード探索のベストプラクティス

TypeScriptプロジェクトでは、以下のコード探索にLSPツールを優先的に使用する (Grep/Glob/Search(pattern:...)より型解決に基づく正確な結果が得られるため):

- `goToDefinition` / `goToImplementation`: シンボルの定義元・インターフェースの実装先を辿る
- `findReferences`: 特定シンボルへの参照を検索する（同名別シンボルの偽陽性を排除できる）
- `hover`: 推論された型情報やコメント・ドキュメントを確認する
- `incomingCalls` / `outgoingCalls`: 関数の呼び出し関係を把握する
- `documentSymbol`: ファイル内のシンボル構造を素早く把握する

ただし、テキストパターンの検索や、ワークスペース全体のシンボル列挙にはGrep/Globを使用する (`workspaceSymbol` は結果が限定的なため)。
