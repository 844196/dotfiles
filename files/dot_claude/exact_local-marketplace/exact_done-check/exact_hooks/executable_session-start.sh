#!/usr/bin/env bash
# SessionStart hook: done-check スキルの起動条件を additionalContext として
# 事前にエージェントへ通知する。
#
# 経緯: SKILL.md の description 内のトリガーフレーズだけだと、
# スキルディスパッチャが取りこぼした場合にチェックが走らない。プラグインは
# rule (paths 付き) を提供できないため、SessionStart で additionalContext を
# 注入することで「事前告知」として補強する。
#
# description マッチは引き続き残るので、エージェントが告知を見逃した場合の
# フェイルセーフとして機能する。
#
# additionalContext の文言は SKILL.md の description と意図的に同期させて
# いる。設計意図の詳細は ../CLAUDE.md (「Skill 起動の促し方」) を参照。

set -euo pipefail

context='[done-check] このセッションでは Done Check スキルが有効です。

ユーザーから受けたタスクを「完了した」と自分で確信したターンで、ユーザーへの返答テキストを書き始める直前に必ず `done-check` スキルを呼んでください。「修正しました」「実装しました」「対応しました」「終わりました」「完了しました」「以上です」「できました」のような完了宣言を書こうとしているとき、また明示的な完了宣言ではなくとも依頼された作業を一通り片付けたと判断したときが対象です。

まだ作業の途中のターン (中間報告、追加情報の要求、これから次のステップに進む宣言など)、および、ファイル変更を一切伴わない純粋な質問への回答のみのターンはスキップしてよい。'

jq -n --arg context "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $context
  }
}'
