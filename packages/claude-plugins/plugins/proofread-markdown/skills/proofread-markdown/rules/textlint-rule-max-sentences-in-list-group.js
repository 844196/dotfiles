"use strict";

const DEFAULT_MAX = 3;

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
      const hasNestedList = node.children.some((child) => child.type === Syntax.List);
      if (!hasNestedList) {
        return;
      }
      const sentenceCount = countSentences(getSource(node));
      if (sentenceCount > max) {
        report(
          node,
          new RuleError(
            `この項目とネストした補足を合わせて${sentenceCount}文になっています（目安: ${max}文まで）。箇条書きは独立した項目の列挙のために使うものです。項目が句点で終わる説明文になっている時点で、それは列挙ではなく段落として書くべき内容です。ファイル名・設定値・用語のような名詞句の列挙（文になっていないもの）はこの指摘の対象外です。「独立した項目の列挙」「話が密接に関連している」を理由にこの指摘を無視しないでください。段落や見出し付きの節への書き直しを検討してください。`
          )
        );
      }
    },
  };
};
