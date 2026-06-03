---
name: takeover
description: ハンドオーバー文書を読んで前セッションの作業を引き継ぐ。
argument-hint: "<handover-doc-filepath>"
---

# Takeover from a handover document

ハンドオーバー文書を読んで、前セッションの作業を引き継ぐ。

## 手順

### 1. ハンドオーバー文書を読む

次のハンドオーバー文書を Read ツールで読み、最終ゴール・セッション中の指示制約・経緯・現在地・次の選択肢を把握する:

`$ARGUMENTS`

### 2. 前セッションを確認する

ハンドオーバー文書の「参考」セクションにある前セッション ID を軸に、次の 2 エージェントを **並列に** spawn して当時の状況を補完する:

1. `session-analyzer:session-analyzer` — 会話内容から意図・経緯・思考過程を補完する。
2. `atuin:command-history-analyzer` — 実行された Bash コマンド (引数・終了コード・時刻・cwd) を時系列で取り出し、ハンドオーバー文書では省略されがちな実コマンドを補完する。

### 3. 次の行動を確認する

引き継いだ内容の理解を元に AskUserQuestion ツールで次の行動を確認する。**いきなり引き継ぎ内容を実行しないこと**。
