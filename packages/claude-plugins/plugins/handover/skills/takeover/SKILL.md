---
name: takeover
description: ハンドオーバー文書を読んで作業を引き継ぐ。
arguments:
  - HANDOVER_DOC_PATH
---

# Takeover from a handover document

ハンドオーバー文書を読んで作業を引き継ぐ。

## 手順

### 1. ハンドオーバー文書を読む

次のハンドオーバー文書を Read ツールで読み、ゴール・指示・制約・経緯・現在地・次の選択肢を把握する: $HANDOVER_DOC_PATH

### 2. 前セッションを確認する

ハンドオーバー文書中に記録されている前セッションIDを軸に、以下のエージェントを **並列に spawn** して当時の状況を補完する:

- `session-analyzer:session-analyzer`: 会話内容から意図・経緯・思考過程を補完する。
- `atuin:command-history-analyzer`: 実行された Bash コマンド (引数・終了コード・時刻・cwd) を時系列で取り出し、ハンドオーバー文書では省略されがちな実コマンドを補完する。

### 3. 次の行動を確認する

引き継いだ内容の理解を元に AskUserQuestion ツールで次の行動を確認する。**いきなり引き継ぎ内容を実行しないこと**。
