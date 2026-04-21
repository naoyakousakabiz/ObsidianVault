#!/bin/bash
# 全 life-reminder 種別を順に Slack へ送信（文面確認用）
# 使い方: bash test-all-life-reminders.sh
# 前提: ~/.config/lifeos/p1-1.env に SLACK_BOT_TOKEN または SLACK_TOKEN（xoxb- / xoxp-）

set -euo pipefail

ENV_FILE="${HOME}/.config/lifeos/p1-1.env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMINDER="${SCRIPT_DIR}/life-reminder.sh"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "エラー: $ENV_FILE が見つかりません" >&2
  exit 1
fi

# 検証は life-reminder.sh に任せる（トークン正規化・xoxb/xoxp 対応）

TYPES=(breakfast lunch snack dinner training work_end voice_journal bedtime)

echo "以下 ${#TYPES[@]} 件を #life-reminder に送ります（各2秒間隔）…"
for t in "${TYPES[@]}"; do
  echo "→ $t"
  bash "$REMINDER" "$t"
  sleep 2
done

echo "完了しました。"
