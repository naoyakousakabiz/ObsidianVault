#!/bin/bash
# 朝のブリーフィング — gog + Slack Bot API
# 毎朝7時に launchd から実行される

set -euo pipefail

mkdir -p ~/scripts

ACCOUNT="naoya.kousaka.biz@gmail.com"
TODAY=$(date "+%Y年%m月%d日(%a)")
_VAULT="${MORNING_BRIEFING_VAULT:-/Users/kousakanaoya/Library/CloudStorage/GoogleDrive-naoya.kousaka.biz@gmail.com/マイドライブ/ObsibianVault}"
DAILY_FILE="$_VAULT/80_Journal/01_Daily/$(date +%Y-%m-%d).md"
ENV_FILE="$HOME/.config/lifeos/p1-1.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

SLACK_TOKEN="${SLACK_BOT_TOKEN:-}"
SLACK_CHANNEL="${P12_SLACK_CHANNEL_ID:-C0ATZUU36RE}"
MENTION_ID="${LIFE_OWNER_SLACK_ID:-U0ARZH32TSQ}"

if [[ -z "$SLACK_TOKEN" ]]; then
  echo "$(date): missing SLACK_BOT_TOKEN" >> ~/scripts/morning_briefing_error.log
  exit 1
fi
if [[ "$SLACK_TOKEN" != xoxb-* ]]; then
  echo "$(date): invalid token type (need xoxb bot token)" >> ~/scripts/morning_briefing_error.log
  exit 1
fi

# ── Calendar: 今日の予定取得 ──────────────────────
CAL_LINES=$(gog calendar events \
  -a "$ACCOUNT" --today -p --results-only 2>/dev/null \
  | tail -n +2 \
  | awk -F'\t' '{printf "• %s〜%s　%s\n", $2, $3, $4}' || true)

[[ -z "$CAL_LINES" ]] && CAL_LINES="なし"

# ── Daily: 今日の優先タスク抽出 ──────────────────────
if [[ -f "$DAILY_FILE" ]]; then
  TASK_LINES=$(awk '
    BEGIN { in_tasks=0; section="" }
    /^## 今日やること/ { in_tasks=1; next }
    in_tasks && /^---/ { in_tasks=0 }
    in_tasks && /^### / { section=$0; sub(/^### /, "", section); next }
    in_tasks && /^[0-9]+\.[[:space:]]*/ {
      line=$0
      sub(/^[0-9]+\.[[:space:]]*/, "", line)
      if (line != "" && line !~ /^（完了）/) {
        if (section != "") {
          printf "• [%s] %s\n", section, line
        } else {
          printf "• %s\n", line
        }
      }
    }
  ' "$DAILY_FILE" | head -10)
else
  TASK_LINES=""
fi

[[ -z "$TASK_LINES" ]] && TASK_LINES="なし"

# ── Block Kit で投稿 ──────────────────────────────
PAYLOAD=$(jq -n \
  --arg channel "$SLACK_CHANNEL" \
  --arg today "$TODAY" \
  --arg mention "$MENTION_ID" \
  --arg cal "$CAL_LINES" \
  --arg tasks "$TASK_LINES" \
'{
  "channel": $channel,
  "text": ("⚡ Good Morning <@" + $mention + ">"),
  "blocks": [
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("⚡ *Good Morning* <@" + $mention + ">  —  " + $today)}
    },
    {"type": "divider"},
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": "*母より*\n\n1.  自分の人生を無駄にしない（命を大切に）\n2.  死を恐れず、今日を全力で\n3.  周りを大切に、伝えられるときに伝える"}
    },
    {"type": "divider"},
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*📅  予定*\n" + $cal)}
    },
    {"type": "divider"},
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*☑️  タスク*\n" + $tasks)}
    }
  ]
}')

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$PAYLOAD" > /dev/null

echo "$(date): morning briefing sent" >> ~/scripts/morning_briefing.log
