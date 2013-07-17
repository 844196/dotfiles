# 使い方
前提としてgitをインストールしてPATHを通しておくこと
以下、ターミナルより

```
$ git remote add origin https://github.com/844196/dotfiles
```

ファイル自体はDropboxで同期してあるのでcloneしなくてよい  
Dropbox入れるの面倒くなったらなにか考える  

子機で設定を変更したら

```
$ git add 変更したファイル
$ git commit -m '変更理由'
$ git push -u
```

でプッシュすること(多分これであってるはず)

