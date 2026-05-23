#!/usr/bin/env bash
# 個人スクラッチパッドディレクトリ (<repo-root>/.844196) のパスを返す。
set -euo pipefail
echo "$(git rev-parse --show-toplevel)/.844196"
