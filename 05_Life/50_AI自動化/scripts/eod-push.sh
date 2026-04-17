#!/usr/bin/env bash
# eod-push.sh — 当日のデイリー（と任意で Vault 変更）を commit / push（ローカル用）
# 任意: GitHub 上の Vault バックアップと同期するため、当日デイリーを push する。
#
# 使い方:
#   cd /path/to/ObsibianVault
#   bash 05_Life/50_AI自動化/scripts/eod-push.sh
#
# 環境変数:
#   LIFEOS_VAULT — Vault ルート（launchd から呼ぶときに指定。未設定なら VAULT → git トップ）
#   VAULT — 同上（後方互換）
#   EOD_PUSH_ALL — 1 ならデイリー以外の変更も add（危険なので任意）

set -euo pipefail

ROOT="${LIFEOS_VAULT:-${VAULT:-}}"
if [[ -n "$ROOT" ]]; then
  cd "$ROOT"
else
  cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || {
    echo "eod-push: cannot find git root; set LIFEOS_VAULT" >&2
    exit 1
  }
fi

TODAY="$(TZ=Asia/Tokyo date +%Y-%m-%d)"
DAILY="80_Journal/01_Daily/${TODAY}.md"

if [[ ! -f "$DAILY" ]]; then
  echo "no daily file: $DAILY — nothing to push" >&2
  exit 1
fi

if [[ "${EOD_PUSH_ALL:-0}" == "1" ]]; then
  git add -A
else
  git add -- "$DAILY"
fi

if git diff --cached --quiet; then
  echo "nothing staged — exit 0"
  exit 0
fi

git commit -m "journal: sync daily ${TODAY}"
git push
