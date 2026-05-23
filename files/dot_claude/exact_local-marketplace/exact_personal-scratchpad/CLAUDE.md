# Personal Scratchpad

`<repository-root>/.844196/` (個人スクラッチパッドディレクトリ) のオーナー。`.844196/` の運用ルール伝達、破壊的操作の警告、ハンドオーバー文書の作成スキル、サブディレクトリ規約をまとめて担当する。

> [!NOTE]
> `**/CLAUDE.md` は [chezmoiignore](../../../.chezmoiignore) で除外されるため、この CLAUDE.md は `~/.claude/local-marketplace/personal-scratchpad/CLAUDE.md` には展開されない。エージェントに対する運用ルールの伝達は [SessionStart hook](exact_hooks/executable_session-start.sh) の `additionalContext` 注入で行う。この CLAUDE.md はソース管理側の開発者向け README として機能する。

## 構成要素

| 要素 | 役割 |
|---|---|
| [`exact_hooks/executable_session-start.sh`](exact_hooks/executable_session-start.sh) | SessionStart で `.844196/` の運用ルール (定義・サブディレクトリ規約・不可逆操作の注意・gitignore 由来の注意) を `additionalContext` で注入 |
| [`exact_hooks/executable_pre-tool.sh`](exact_hooks/executable_pre-tool.sh) | PreToolUse で `.844196/` を含むパスへの Edit/Write/Bash 操作を検出して警告を注入 |
| [`exact_bin/executable_scratchpad-root.sh`](exact_bin/executable_scratchpad-root.sh) | `<repository-root>/.844196` を echo する裸コマンド。他プラグインから PATH 経由で使える |
| [`exact_bin/executable_handover-path.sh`](exact_bin/executable_handover-path.sh) | 新規ハンドオーバー文書のパス候補 (`<root>/handovers/<datetime>_<kebab>.md`) を echo |
| [`handover-tmux` スキル](exact_skills/exact_handover-tmux/SKILL.md) | 会話をハンドオーバー文書に書き出し、tmux の新ペインで新セッションを起動して引き継ぐ |
| [`handover-tomorrow` スキル](exact_skills/exact_handover-tomorrow/SKILL.md) | 会話をハンドオーバー文書に書き出す (新セッション起動は伴わない) |

## サブディレクトリ規約

```
<repository-root>/.844196/
  plans/        # 実装計画・設計メモ
  reports/      # 調査・分析のレポート
  handovers/    # ハンドオーバー文書 (handover-* スキルが書き出す)
  logs/         # 実験のために書き出したログ
  scripts/      # ユーザーが個人で使う補助スクリプト
```

具体的なルール本文は [SessionStart hook](exact_hooks/executable_session-start.sh) の注入メッセージにまとめてある。書き換える場合はそちら。

## なぜプラグインに集約したか

以前は `.844196/` 関連の知識・コードが以下に散在していた:

- `scratch-dir-warning` プラグイン (操作警告 hook)
- `session` プラグイン (handover 系 skill / bin)
- `~/.claude/rules/personal-scratch-directory.md` (定義と運用ルール)

それぞれが独立に `.844196/` の知識を持ち、ルールの追加 (e.g. `.844196/reports/` のフォーマット規約) を入れる場所が不明瞭だった。`.844196/` 全責務を本プラグインに集約することで、将来サブディレクトリごとの規則・スキルを足す際の場所が明確になる。

## 他プラグインからの参照

- [atuin](../exact_atuin/CLAUDE.md): `recall-commands` スキルがハンドオーバー文書を入口にするため `dependencies` に宣言
- [edit-reminders](../exact_edit-reminders/CLAUDE.md): `.844196/` 除外設計の前提として `dependencies` に宣言
