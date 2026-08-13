# herdr 経由で自由記述テキストを送るとき

`herdr agent prompt <target> "<text>"` や `herdr pane run <id> "<text>"` のように、自由記述テキスト（説明文・要約・他ファイルからの引用など）をシェルコマンドの引数としてダブルクォートでそのまま埋め込んではいけない。
Markdown のコードスパン (`` `...` ``) や `$(...)` を含む文字列をダブルクォート内に書くと、bash はコマンドを実行する前にそれをコマンド置換として評価してしまう。ほとんどは `command not found` / `No such file or directory` で無害に終わるが、引用の中身がたまたま実在する破壊的コマンド（`git reset --hard`、`rm -rf` など）と一致すると、引用のつもりが実際にそのまま実行されてしまう。

自由記述テキストは **Write ツール（または Edit ツール）で一時ファイルに直接書き込み**、Bash ツールにはファイルパスの参照だけを渡す:

1. Write ツールで `/tmp/herdr-msg.txt` のようなパスへ自由記述テキストをそのまま書き込む
2. Bash ツールでは固定形式のコマンドだけを実行する:

   ```bash
   herdr agent prompt <target> "$(cat /tmp/herdr-msg.txt)"
   ```

この作法は `herdr` に限らず、tmux の `send-keys` など「自由記述テキストをシェルコマンドの引数として他プロセスに渡す」操作全般に当てはまる。
