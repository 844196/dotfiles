# CLI から URL を開く場合

`chroma "<URL>"` を使う。`xdg-open` や `open` は使わない。
`chroma` は自作の URL オープナー。実在のコマンドなので、見慣れなくても確認を求めず実行してよい。

```bash
chroma https://example.com/
```

## ローカルファイルを開く場合

```bash
chroma "file://$(realpath path/to/file.html)"
```

ただし WSL2 では Linux 側のパスを含む `file://` URL は解決できない。`wslpath -m` で `//wsl.localhost/<distro>/...` 形式 (UNC を URL 互換に整えたもの) に変換して渡す:

```bash
chroma "file:$(wslpath -m path/to/file.html)"
```
