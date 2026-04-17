#!/bin/bash
# life-reminder — 食事・補食・トレーニング通知
# 使い方: life-reminder.sh <TYPE>
#   TYPE: breakfast / lunch / snack / dinner / training
#
# launchd から各時刻に呼び出す（~/Library/LaunchAgents/com.lifeos.reminder-*.plist）

set -euo pipefail

TYPE="${1:-}"
ENV_FILE="$HOME/.config/lifeos/p1-1.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

SLACK_TOKEN="${SLACK_BOT_TOKEN:-}"
SLACK_CHANNEL="${LIFE_REMINDER_SLACK_CHANNEL_ID:-C0ASQ7MTL7R}"
MENTION_ID="${LIFE_OWNER_SLACK_ID:-U0ARZH32TSQ}"

if [[ -z "$SLACK_TOKEN" ]]; then
  echo "$(date): missing SLACK_BOT_TOKEN" >&2
  exit 1
fi
if [[ "$SLACK_TOKEN" != xoxb-* ]]; then
  echo "$(date): invalid token type" >&2
  exit 1
fi

case "$TYPE" in
  breakfast)
    EMOJI="🍳"
    TEXT="朝食の時間です。しっかり食べてスタートしましょう。"
    ;;
  lunch)
    EMOJI="🍱"
    TEXT="昼食の時間です。午後に備えてしっかり補給しましょう。"
    ;;
  snack)
    EMOJI="🥜"
    TEXT="補食タイムです。トレ前・午後の集中維持に食べておきましょう。"
    ;;
  dinner)
    EMOJI="🍽️"
    TEXT="夕食の時間です。今日の疲れをリカバリーする食事を。"
    ;;
  training)
    EMOJI="🏃"
    TEXT="トレーニングの時間です。今日のメニューを確認して始めましょう。"
    ;;
  *)
    echo "Usage: $0 <breakfast|lunch|snack|dinner|training>" >&2
    exit 1
    ;;
esac

PAYLOAD=$(jq -n \
  --arg channel "$SLACK_CHANNEL" \
  --arg mention "$MENTION_ID" \
  --arg emoji "$EMOJI" \
  --arg text "$TEXT" \
'{
  "channel": $channel,
  "text": ($emoji + " <@" + $mention + "> " + $text),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ($emoji + " <@" + $mention + ">  " + $text)
      }
    }
  ]
}')

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$PAYLOAD" > /dev/null

echo "$(date): reminder sent [$TYPE]" >> ~/scripts/life-reminder.log
