#!/bin/bash
# life-reminder — 食事・補食・トレ・日課通知
# 使い方: life-reminder.sh <TYPE>
#   TYPE: breakfast / lunch / snack / dinner / training /
#         work_end / voice_journal / bedtime
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
    TEXT="朝食の時間です。しっかり摂り、午前の活動に備えましょう。"
    ;;
  lunch)
    EMOJI="🍱"
    TEXT="昼食の時間です。午後の予定に向けて、十分に補給しましょう。"
    ;;
  snack)
    EMOJI="🥜"
    TEXT="補食の時間です。トレーニングや午後の業務に備え、適宜摂取しましょう。"
    ;;
  dinner)
    EMOJI="🥗"
    TEXT="夕食の時間です。"
    ;;
  training)
    EMOJI="🏃‍♂️"
    TEXT="トレーニングの時間です。週間メニューは下記をご確認ください。"
    ;;
  work_end)
    EMOJI="🏃‍♂️"
    TEXT="仕事を20時までには終えて、ジムに向かいましょう。"
    ;;
  voice_journal)
    EMOJI="🎤"
    TEXT="今すぐ音声ジャーナルを1、2分で作成しましょう。"
    ;;
  bedtime)
    EMOJI="🛌✨"
    TEXT="早く寝るためにベッドに入りましょう。"
    ;;
  *)
    echo "Usage: $0 <breakfast|lunch|snack|dinner|training|work_end|voice_journal|bedtime>" >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# トレーニング時は週間メニュー全文（正本: 09_Athlete/10_トライアスロン/週間練習メニュー.md）
MENU_BODY=""
# 食事系は種別ごとの栄養ポイント（正本: 09_Athlete/70_食事/食事リマインド本文.md）
MEAL_BODY=""
MEAL_LABEL=""

if [[ "$TYPE" == "training" ]]; then
  MENU_FILE=""
  if [[ -n "${LIFE_TRAINING_WEEKLY_MENU_FILE:-}" && -f "${LIFE_TRAINING_WEEKLY_MENU_FILE}" ]]; then
    MENU_FILE="$LIFE_TRAINING_WEEKLY_MENU_FILE"
  else
    CANDIDATE="$SCRIPT_DIR/../../../09_Athlete/10_トライアスロン/週間練習メニュー.md"
    if [[ -f "$CANDIDATE" ]]; then
      MENU_FILE="$CANDIDATE"
    elif [[ -f "${HOME}/.config/lifeos/training-weekly-menu.md" ]]; then
      MENU_FILE="${HOME}/.config/lifeos/training-weekly-menu.md"
    fi
  fi
  if [[ -z "$MENU_FILE" || ! -f "$MENU_FILE" ]]; then
    echo "$(date): training: weekly menu file not found (LIFE_TRAINING_WEEKLY_MENU_FILE or Vault path or ~/.config/lifeos/training-weekly-menu.md)" >&2
    exit 1
  fi
  MENU_BODY=$(awk 'BEGIN{fs=0} /^---$/ {fs++; next} fs>=2 {print}' "$MENU_FILE")
  if [[ -z "$MENU_BODY" ]]; then
    MENU_BODY=$(cat "$MENU_FILE")
  fi
elif [[ "$TYPE" == "breakfast" || "$TYPE" == "lunch" || "$TYPE" == "snack" || "$TYPE" == "dinner" ]]; then
  MEAL_FILE=""
  if [[ -n "${LIFE_MEAL_REMINDER_BODIES_FILE:-}" && -f "${LIFE_MEAL_REMINDER_BODIES_FILE}" ]]; then
    MEAL_FILE="${LIFE_MEAL_REMINDER_BODIES_FILE}"
  else
    CANDIDATE="$SCRIPT_DIR/../../../09_Athlete/70_食事/食事リマインド本文.md"
    if [[ -f "$CANDIDATE" ]]; then
      MEAL_FILE="$CANDIDATE"
    elif [[ -f "${HOME}/.config/lifeos/meal-reminder-bodies.md" ]]; then
      MEAL_FILE="${HOME}/.config/lifeos/meal-reminder-bodies.md"
    fi
  fi
  if [[ -z "$MEAL_FILE" || ! -f "$MEAL_FILE" ]]; then
    echo "$(date): meal: bodies file not found (LIFE_MEAL_REMINDER_BODIES_FILE or Vault path or ~/.config/lifeos/meal-reminder-bodies.md)" >&2
    exit 1
  fi
  MEAL_BODY=$(awk -v sec="$TYPE" '$0 ~ "^### " sec "$" { p=1; next } /^### / { if (p) exit } p { print }' "$MEAL_FILE")
  if [[ -z "$MEAL_BODY" ]]; then
    echo "$(date): meal: section ### $TYPE not found in $MEAL_FILE" >&2
    exit 1
  fi
  case "$TYPE" in
    breakfast) MEAL_LABEL="朝食" ;;
    lunch)     MEAL_LABEL="昼食" ;;
    snack)     MEAL_LABEL="補食" ;;
    dinner)    MEAL_LABEL="夕食" ;;
  esac
fi

if [[ "$TYPE" == "training" ]]; then
  PAYLOAD=$(jq -n \
    --arg channel "$SLACK_CHANNEL" \
    --arg mention "$MENTION_ID" \
    --arg emoji "$EMOJI" \
    --arg text "$TEXT" \
    --arg body "$MENU_BODY" \
'{
  "channel": $channel,
  "text": ($emoji + " <@" + $mention + "> " + $text + "\n\n" + $body),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ($emoji + " <@" + $mention + ">  " + $text)
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("*【週間練習メニュー】*\n\n" + $body)
      }
    }
  ]
}')
elif [[ "$TYPE" == "breakfast" || "$TYPE" == "lunch" || "$TYPE" == "snack" || "$TYPE" == "dinner" ]]; then
  PAYLOAD=$(jq -n \
    --arg channel "$SLACK_CHANNEL" \
    --arg mention "$MENTION_ID" \
    --arg emoji "$EMOJI" \
    --arg text "$TEXT" \
    --arg body "$MEAL_BODY" \
    --arg title "$MEAL_LABEL" \
'{
  "channel": $channel,
  "text": ($emoji + " <@" + $mention + "> " + $text + "\n\n" + $body),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ($emoji + " <@" + $mention + ">  " + $text)
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("*【" + $title + "のポイント（栄養）】*\n\n" + $body)
      }
    }
  ]
}')
elif [[ "$TYPE" == "voice_journal" ]]; then
  if [[ -n "${LIFE_VOICE_SLACK_LINK:-}" ]]; then
    PAYLOAD=$(jq -n \
      --arg channel "$SLACK_CHANNEL" \
      --arg mention "$MENTION_ID" \
      --arg emoji "$EMOJI" \
      --arg text "$TEXT" \
      --arg vlink "$LIFE_VOICE_SLACK_LINK" \
'{
  "channel": $channel,
  "text": ($emoji + " <@" + $mention + "> " + $text),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ($emoji + " <@" + $mention + ">  " + $text + "\n\n<" + $vlink + "|音声チャンネルへ>")
      }
    }
  ]
}')
  else
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
        "text": ($emoji + " <@" + $mention + ">  " + $text + "\n\n（音声チャンネル URL を p1-1.env の LIFE_VOICE_SLACK_LINK に設定してください）")
      }
    }
  ]
}')
  fi
else
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
fi

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$PAYLOAD" > /dev/null

# p1-1.env と同じ ~/.config/lifeos/ にログ（CI では親ディレクトリが無いことがある）
LOG_FILE="${HOME}/.config/lifeos/life-reminder.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date): reminder sent [$TYPE]" >> "$LOG_FILE"
