---
name: proofread-markdown
description: 外部公開向け Markdown 文書の校正。校正・textlint チェックを求められたら使う。
allowed-tools:
  - Bash(${CLAUDE_SKILL_DIR}/scripts/proofread-markdown.sh *)
---

外部公開向け Markdown 文書を校正する。textlint・markdownlint の指摘は、元の意図を保ったまま修正できるものだけ反映する。指摘が厳しすぎて修正するとかえって意図が伝わりにくくなる場合は、その指摘を無視してよい。

textlint のルール設定は `${CLAUDE_SKILL_DIR}/textlintrc.json`、markdownlint のルール設定は `${CLAUDE_SKILL_DIR}/markdownlintrc.json` にまとめてある。

## 手順

1. 次のコマンドで textlint と markdownlint を実行する。

   ```bash
   ${CLAUDE_SKILL_DIR}/scripts/proofread-markdown.sh path/to/doc.md
   ```

2. 指摘それぞれについて、修正するか無視するかを判断する。全ての指摘に判断がついたら次に進む。
3. 自動修正できる指摘は、次のコマンドでまとめて修正する。

   ```bash
   ${CLAUDE_SKILL_DIR}/scripts/proofread-markdown.sh --fix path/to/doc.md
   ```

4. 自動修正の対象外だが修正すると判断した指摘は、手作業で反映する。
5. 手順3・4で1件でも修正した場合は、手順1に戻って再チェックする。修正が新たな指摘を生むことがあるため、指摘が残らなくなるか、残った指摘が全て無視すると判断したものになるまで繰り返す。
6. 無視した指摘があれば、理由を添えて報告する。
