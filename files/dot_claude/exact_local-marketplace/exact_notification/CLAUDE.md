# Notification

Claude Code の `Notification` / `Stop` イベントで、tmux のベル (`monitor-bell`) と OS のデスクトップ通知 (macOS バナー / Windows トースト) を発火させる hook 群。エージェントが入力待ちになったときや応答を返し終わったときに、ターミナルから目を離していても気づけるようにする。

## What It Does

| Hook | Event | 動作 |
|---|---|---|
| [`bell.sh`][bell] | `Notification` / `Stop` | Claude のペインの tty に `\a` (BEL) を書き出し、tmux の `monitor-bell` を発火させる |
| [`notify-darwin.sh`][notify-darwin] | `Notification` (macOS のみ) | hook input の `message` を `osascript` で macOS Notification Center にバナー表示 |
| [`notify-windows.sh`][notify-windows] | `Notification` (それ以外 = WSL2 想定) | hook input の `message` を `powershell.exe` 経由で Windows のトースト通知として表示 |

`Notification` はエージェントが入力待ち・許可待ちになった瞬間、`Stop` はターン終了時に発火する。[`bell.sh`][bell] は両方で鳴らし、OS 通知系は `Notification` のみ (Stop で毎ターン OS 通知が出ると煩いため)。

[`hooks.json.tmpl`](exact_hooks/hooks.json.tmpl) を chezmoi テンプレート化し、`{{ if eq .chezmoi.os "darwin" }}` で `Notification` に登録するスクリプトを [`notify-darwin.sh`][notify-darwin] / [`notify-windows.sh`][notify-windows] のどちらかに切り替える。両方の `.sh` は target にデプロイされるが、`hooks.json` から参照されるのは片方だけなので実害はない。

## How It Works

### bell.sh

hook の起動コンテキストでは `/dev/tty` が Claude のペインの tty に解決されないため、`$TMUX_PANE` から `tmux display-message` でペインの tty を引いて、そこに `printf '\a'` を書き出している。tmux 側で `set -g monitor-bell on` していればベル発火が拾われ、status line への通知や `bell-action` の挙動に繋がる。

tmux 外で起動された場合は何もせず exit 0 する。

### notify-darwin.sh

`osascript -e 'display notification ...'` で macOS の Notification Center にバナーを出す。

### notify-windows.sh

`powershell.exe` 経由で `Windows.UI.Notifications.ToastNotificationManager` を叩いてトースト通知を出す。`scenario="reminder"` を付けてユーザーが閉じるまで残す。

両 OS スクリプトとも、メッセージは hook input の `.message` を使い、欠落時は `"通知があります"` をフォールバック。

## Configuration

このプラグインを有効化するには、Claude Code の `settings.json` で:

```json
{
  "extraKnownMarketplaces": {
    "local": {
      "source": {
        "source": "directory",
        "path": "/path/to/local-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "notification@local": true
  }
}
```

tmux 側で `monitor-bell` を有効にしておくとベルが拾われる:

```tmux
set -g monitor-bell on
set -g bell-action other
```

[bell]: exact_hooks/executable_bell.sh
[notify-darwin]: exact_hooks/executable_notify-darwin.sh
[notify-windows]: exact_hooks/executable_notify-windows.sh
