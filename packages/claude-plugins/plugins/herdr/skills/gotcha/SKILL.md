---
name: gotcha
description: herdr の `agent prompt` / `pane run` など自由記述テキストをシェル引数として他プロセスへ渡す操作を行う前、および herdr 経由の操作で想定外の挙動・エラーに遭遇したときに参照する。herdr 本体のスキルは CLI の構文は教えてくれるが、実運用でハマった罠までは教えてくれないため、それを補うリファレンス。
---

# Herdr の罠

herdr 本体のスキルは CLI の使い方 (構文) を教えてくれるが、"どう事故るか" までは教えてくれない。ここでは実運用で実際に踏んだ罠と対処法をまとめる。

## 罠: 自由記述テキストのダブルクォート直書き → コマンド置換の誤爆

`herdr agent prompt <target> "<text>"` や `herdr pane run <id> "<text>"` のように、説明文・要約・他ファイルからの引用などの自由記述テキストをシェルコマンドの引数としてダブルクォートでそのまま埋め込んではいけない。

Markdown のコードスパン (`` `...` ``) や `$(...)` を含む文字列をダブルクォート内に書くと、bash はコマンドを実行する前にそれをコマンド置換として評価してしまう。ほとんどは `command not found` / `No such file or directory` で無害に終わるが、引用の中身がたまたま実在する破壊的コマンド (`git reset --hard`、`rm -rf` など) と一致すると、引用のつもりが実際にそのまま実行されてしまう。

**実際に起きた事故**: あるセッションで、調査結果を子エージェントに伝えるメッセージ本文に「`` `git reset --hard HEAD~` が実行されて壊れた」という説明を引用として書いた。この本文をそのままダブルクォートに埋め込んで `herdr agent prompt` に渡したところ、引用のつもりで書いた `git reset --hard HEAD~` がコマンド置換として実際に実行され、直近のコミット (実装一式を含む squash commit) がまるごと失われた。dangling commit として git オブジェクトに残っていたため復旧できたが、`git gc` のタイミング次第では完全に消えていた。

**対策**: 自由記述テキストは Write ツール (または Edit ツール) で一時ファイルに直接書き込み、Bash ツールにはファイルパスの参照だけを渡す。

1. Write ツールで `/tmp/herdr-msg.txt` のようなパスへ自由記述テキストをそのまま書き込む
2. Bash ツールでは固定形式のコマンドだけを実行する:

   ```bash
   herdr agent prompt <target> "$(cat /tmp/herdr-msg.txt)"
   ```

## 罠: 事故で壊れたメッセージの後始末に手間取る

上記の事故 (あるいは単なる誤送信) で対象ペインの入力行が中途半端な状態になったとき、`esc` 一発だけでは入力行が消えないことがある。消えたかどうか確認せずに送り直すと、二重入力や意図しないキー入力の混入につながり、かえって手間取る。

**対策**: 送信し直す前に、次の順で確実にクリアしてから空になったことを確認する。

```bash
herdr agent send-keys <target> esc
herdr agent send-keys <target> ctrl+c
herdr agent send-keys <target> ctrl+u
herdr agent read <target> --source recent-unwrapped --lines 5   # 入力行が空になったか確認してから次を送る
```

`ctrl+u` (行全体を削除) まで試しても残る場合は、原因 (バックティック展開・意図しない改行の混入など) を特定してから送り直す。原因を特定しないままの再送は同じ事故を繰り返すリスクがある。

## 罠: `HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` は自分が `pane move` された後は古いままになる

`HERDR_PANE_ID` / `HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` は herdr が pane 起動時に注入する環境変数で、OS の環境変数である以上その後 herdr 側の状態が変わっても自動更新されない。自分の pane が `herdr pane move` で他の tab/workspace に移動された場合、`HERDR_PANE_ID` は生きている pane を指し続けるので実害は無いが、`HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` は移動前の値のまま古くなる。

**対策**: 自分がいつ `pane move` されたか分からない (他エージェントや人間が操作した可能性がある) 場合、`HERDR_TAB_ID` / `HERDR_WORKSPACE_ID` を鵜呑みにせず、`herdr pane current --current` の応答 (`tab_id` / `workspace_id`) を都度問い合わせて使う。`HERDR_PANE_ID` はこの用途において比較的信頼できるが、それでも疑わしければ同じコマンドで裏取りする。
