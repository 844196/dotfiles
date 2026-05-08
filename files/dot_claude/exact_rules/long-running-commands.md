# 長時間コマンドの出力を確実に残す

ビルド、デプロイ、大規模テストなど **実行に時間がかかるコマンド・再実行コストが高いコマンド** は、出力を手元に残しておくと安心。後から見返せるし、途中で切れても慌てずに済む。

## 方法 1: `run_in_background` (おすすめ)

Bash ツールの `run_in_background: true` を使うと、出力は自動でファイルに保存される。完了時に通知が届くので、他の作業を進めながら待てる。

```json
{
  "command": "npm run build",
  "run_in_background": true
}
```

出力が必要になったら、通知で示されたパスを Read で開くだけ。

## 方法 2: `tee` でログに残す

フォアグラウンドで実行しつつ出力を残したいときは `tee` を使う。

```bash
npm run build 2>&1 | tee /tmp/build-$(date +%s).log
mise run deploy 2>&1 | tee /tmp/deploy-$(date +%s).log
```

## 出力が途中で切れてしまったら

再実行しなくていい。保存したログファイルを Read で読めば、全文が手に入る。
