[ctx](https://ctx.rs/) には本来ビルトインの [SKILL.md](https://github.com/ctxrs/ctx/blob/main/skills/ctx-agent-history-search/SKILL.md) が付属しているが、内容が不十分であるため自作している。

自作にあたっては、ビルトイン SKILL.md に欠けている以下に重点を置く:

- 自明な前提を確認させない
- ctx 特有の概念説明を追加
- 普段使用しないサブコマンドの説明を削除
- エージェントが混乱する使用例の削除
- 具体的な使用例を追加
- ハマりどころの補完

動作確認には Claude Code セッション ID: `0dbfc439-394c-476a-916a-8ee13bdf1eeb` (433.2k tokens) を使用すること
