# hooks/mise-hook-env.sh の取り扱いについて

以下の理由により [`mise-hook-env.sh`](./exact_hooks/executable_mise-hook-env.sh) は凍結されています:

- [Claude Code 側のバグ](https://github.com/search?q=repo%3Aanthropics%2Fclaude-code%20CLAUDE_ENV_FILE&type=issues) により、安定した挙動を保証できない
- `mise hook-env` が [Claude Codeが各プラグインの `bin/` への `PATH` 追加](https://code.claude.com/docs/en/plugins-reference#file-locations-reference) を打ち消してしまう

コードは現状が維持されます
