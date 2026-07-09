#!/bin/bash
# セッション開始時にエージェント実行環境の情報を注入する motd (message of the day)。
# 各セクションを関数として定義し、run で並べる。将来 fastfetch 以外の情報を足すときは
# 関数を追加して run に足すだけでよい。

cat >/dev/null  # stdin の hook input は捨てる

section_fastfetch() {
  command -v fastfetch >/dev/null 2>&1 || return 0
  fastfetch --logo none --structure-disabled colors
}

run() {
  section_fastfetch
}

run

exit 0
