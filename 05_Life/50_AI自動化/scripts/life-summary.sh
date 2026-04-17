#!/bin/bash
# life-summary — 夜サマリ → #life-summary
# 毎日 21:00 に launchd から実行（com.lifeos.life-summary.plist）
#
# Daily ノートから当日タスクを集計し、進捗・気づき・翌日最優先3件を通知する

set -euo pipefail

VAULT="${LIFE_SUMMARY_VAULT:-/Users/kousakanaoya/Library/CloudStorage/GoogleDrive-naoya.kousaka.biz@gmail.com/マイドライブ/ObsibianVault}"
TODAY=$(TZ=Asia/Tokyo date +%Y-%m-%d)
TODAY_JP=$(TZ=Asia/Tokyo date "+%Y年%m月%d日(%a)")
DAILY_FILE="$VAULT/80_Journal/01_Daily/$TODAY.md"
ENV_FILE="$HOME/.config/lifeos/p1-1.env"

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

SLACK_TOKEN="${SLACK_BOT_TOKEN:-}"
SLACK_CHANNEL="${LIFE_SUMMARY_SLACK_CHANNEL_ID:-C0ATJHX5Z17}"
MENTION_ID="${LIFE_OWNER_SLACK_ID:-U0ARZH32TSQ}"

if [[ -z "$SLACK_TOKEN" ]]; then
  echo "$(date): missing SLACK_BOT_TOKEN" >&2
  exit 1
fi
if [[ "$SLACK_TOKEN" != xoxb-* ]]; then
  echo "$(date): invalid token type" >&2
  exit 1
fi

# ── Daily ノートからタスクを集計 ─────────────────────────
if [[ ! -f "$DAILY_FILE" ]]; then
  DONE_COUNT=0
  INPROG_COUNT=0
  PENDING_COUNT=0
  TOTAL_COUNT=0
  DONE_LINES="（Daily ノートが見つかりませんでした）"
  INPROG_LINES=""
  PENDING_LINES=""
  MEMO_LINES="なし"
else
  # 完了・進行中・未着手を集計
  DONE_LINES=$(awk '
    /^## 今日やること/ { in_tasks=1; next }
    in_tasks && /^---/ { in_tasks=0 }
    in_tasks && /^[0-9]+\.[[:space:]].*（完了）/ {
      line=$0; sub(/^[0-9]+\.[[:space:]]*/, "", line)
      print "• " line
    }
  ' "$DAILY_FILE")

  INPROG_LINES=$(awk '
    /^## 今日やること/ { in_tasks=1; next }
    in_tasks && /^---/ { in_tasks=0 }
    in_tasks && /^[0-9]+\.[[:space:]]/ {
      line=$0; sub(/^[0-9]+\.[[:space:]]*/, "", line)
      if (line ~ /（進行中）/ || line ~ /（作業中）/) print "• " line
    }
  ' "$DAILY_FILE")

  PENDING_LINES=$(awk '
    /^## 今日やること/ { in_tasks=1; next }
    in_tasks && /^---/ { in_tasks=0 }
    in_tasks && /^[0-9]+\.[[:space:]]/ {
      line=$0; sub(/^[0-9]+\.[[:space:]]*/, "", line)
      if (line !~ /（完了）/ && line !~ /（進行中）/ && line !~ /（作業中）/ && line !~ /（中止）/ && line != "") print "• " line
    }
  ' "$DAILY_FILE")

  DONE_COUNT=$(echo "$DONE_LINES" | grep -c "^•" 2>/dev/null || echo 0)
  INPROG_COUNT=$(echo "$INPROG_LINES" | grep -c "^•" 2>/dev/null || echo 0)
  PENDING_COUNT=$(echo "$PENDING_LINES" | grep -c "^•" 2>/dev/null || echo 0)
  TOTAL_COUNT=$((DONE_COUNT + INPROG_COUNT + PENDING_COUNT))

  [[ -z "$DONE_LINES" ]]    && DONE_LINES="なし"
  [[ -z "$INPROG_LINES" ]]  && INPROG_LINES="なし"
  [[ -z "$PENDING_LINES" ]] && PENDING_LINES="なし"

  # メモ・気づきを抽出（最大3行）
  MEMO_LINES=$(awk '
    /^## メモ・気づき/ { in_memo=1; next }
    in_memo && /^---/ { in_memo=0 }
    in_memo && /^- .+/ { print $0 }
  ' "$DAILY_FILE" | head -3)
  [[ -z "$MEMO_LINES" ]] && MEMO_LINES="なし"
fi

# 明日の最優先3件は手動追記用のプレースホルダ（Daily更新後に反映される）
TOMORROW_TASKS="（明日のDailyで確認）"

# ── Slack 投稿 ──────────────────────────────────────────
PROGRESS_BAR=""
if [[ "$TOTAL_COUNT" -gt 0 ]]; then
  FILLED=$(( DONE_COUNT * 10 / TOTAL_COUNT ))
  for i in $(seq 1 $FILLED);   do PROGRESS_BAR="${PROGRESS_BAR}█"; done
  for i in $(seq 1 $((10 - FILLED))); do PROGRESS_BAR="${PROGRESS_BAR}░"; done
  PROGRESS_BAR="${PROGRESS_BAR} ${DONE_COUNT}/${TOTAL_COUNT}"
else
  PROGRESS_BAR="── 0/0"
fi

PAYLOAD=$(jq -n \
  --arg channel "$SLACK_CHANNEL" \
  --arg today "$TODAY_JP" \
  --arg mention "$MENTION_ID" \
  --arg progress "$PROGRESS_BAR" \
  --arg done_lines "$DONE_LINES" \
  --arg inprog_lines "$INPROG_LINES" \
  --arg pending_lines "$PENDING_LINES" \
  --arg memo_lines "$MEMO_LINES" \
  --arg tomorrow "$TOMORROW_TASKS" \
'{
  "channel": $channel,
  "text": ("🌙 夜サマリ <@" + $mention + ">"),
  "blocks": [
    {
      "type": "header",
      "text": {"type": "plain_text", "text": ("🌙 " + $today + " 夜サマリ")}
    },
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("<@" + $mention + "> お疲れさまでした")}
    },
    {"type": "divider"},
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*📊 今日の進捗*\n" + $progress)}
    },
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*✅ 完了*\n" + $done_lines)}
    },
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*🔄 進行中*\n" + $inprog_lines)}
    },
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*⬜ 未着手*\n" + $pending_lines)}
    },
    {"type": "divider"},
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*💡 今日の気づき*\n" + $memo_lines)}
    },
    {"type": "divider"},
    {
      "type": "section",
      "text": {"type": "mrkdwn", "text": ("*🎯 明日の最優先3件*\n" + $tomorrow)}
    }
  ]
}')

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$PAYLOAD" > /dev/null

LOG_FILE="${HOME}/.config/lifeos/life-summary.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date): life-summary sent" >> "$LOG_FILE"
