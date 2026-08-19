"use strict";

const DEFAULT_MAX = 2;

function countSentences(text) {
  const trimmed = text.trim();
  if (!trimmed) {
    return 0;
  }
  const terminated = trimmed.match(/[^。]*。/g) || [];
  const remainder = trimmed.slice(terminated.join("").length).trim();
  return terminated.length + (remainder ? 1 : 0);
}

module.exports = function (context, options = {}) {
  const { Syntax, RuleError, report, getSource } = context;
  const max = options.max || DEFAULT_MAX;
  return {
    [Syntax.ListItem](node) {
      const textNodes = node.children.filter((child) => child.type !== Syntax.List);
      if (textNodes.length === 0) {
        return;
      }
      const text = textNodes.map((child) => getSource(child)).join("");
      const sentenceCount = countSentences(text);
      if (sentenceCount > max) {
        report(
          node,
          new RuleError(
            `箇条書き1項目が${sentenceCount}文になっています（目安: ${max}文まで）。箇条書きは独立した項目の列挙のために使うものです。項目が句点で終わる説明文になっている時点で、それは列挙ではなく段落として書くべき内容です。「項目同士が独立している」「話が密接に関連している」を理由にこの指摘を無視しないでください。項目を分割するのではなく、箇条書きをやめて段落や見出し付きの節に書き直すことを検討してください。`
          )
        );
      }
    },
  };
};
