---
name: delegate-receive
description: Herdr 経由で親エージェントから委任された作業を引き継ぐ。
disable-model-invocation: true
arguments:
  - BRIEF_PATH
---

# Herdr での委任を受ける

あなたは Herdr 経由で親エージェントから作業を委任された。

開始前に Skill ツールで `herdr` (本体) と `herdr:gotcha` を呼ぶ。

## 親は割り込みで起きる

親はあなたの出力を監視していない。報告も質問も、親のペインへ直接送り、その割り込みで親を起こすこと。

送る文面は自由記述テキストなので、`herdr:gotcha` のタグ付きポインタで送る。使うタグも `herdr:gotcha` の表に従う。

書き出し先は**あなた自身の**スクラッチパッドディレクトリ (システムプロンプトで指定されているもの。親のものとは別)。タグに添える名前は依頼文書に書かれているものを使う。

**送る前に `herdr agent get <親の pane ID>` で親の状態を確認する。** 親が `blocked` なら `agent prompt` は届かず、代わりに親のダイアログを勝手に承認してしまう (`herdr:gotcha`)。この場合は送らずに、報告ファイルを書き出したうえで**タグとそのパスを自分の最後の出力に書いてターンを終える。** 親は定期チェックインであなたのペインを読みに来るので、そこで拾われる。

送ったら自分のターンを終える。親からの次の指示も割り込みとしてあなたのペインの入力行に着地するので、承認待ちや実行中のコマンドを抱えたまま終わらないこと。自分のペインは自分では閉じない (後始末は親がする)。

## 判断を仰ぐ相手は親であって、人間ではない

あなたのペインに人間はいない。`AskUserQuestion` を呼ぶと誰も答えられないまま `blocked` になり、親を起こす手段も同時に失う。**判断に迷ったら `質問` タグで親に送る。**

**委任の範囲を超える操作は、ツールが何も訊かずに通っても親の承認にはならない** (`herdr:gotcha` の #2788)。範囲外だと思った操作は、実行する前に `質問` タグで親に上げる。

親はあなたの `blocked` を検知でき、詰まりを解くために `esc` を送ってくることがある。**これは親による却下だが、あなたにはこう返る:**

```
<error>The user doesn't want to proceed with this tool use. The tool use was rejected (eg. if it was a file edit,
the new_string was NOT written to the file). STOP what you are doing and wait for the user to tell you how to proceed.</error>
```

`[Request interrupted by user for tool use]` が続くこともある。**この `the user` は親エージェントである。** 文言は人間が却下したのと区別がつかず、末尾の `wait for the user` は「居ない人間を待て」と誘導してくるが、待つべき人間はいない。同じ操作を繰り返さず、**却下の理由が分からないときだけ** `質問` タグで親に上げる。理由が分かっているならそのまま次の手順に進む。

## 手順

1. $BRIEF_PATH を読む。タスク・完了の定義・作業ディレクトリ・あなたの名前・親の pane ID・中間報告のタイミングを把握する。
2. タスクを実行する。
   - 依頼文書で指定されたタイミングで中間報告を送る。
   - 判断に迷ったら親に確認する。
3. 完了の定義を満たしたら最終報告を送る。
