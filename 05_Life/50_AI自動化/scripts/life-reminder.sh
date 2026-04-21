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

# SLACK_BOT_TOKEN または SLACK_TOKEN（どちらか）。CRLF・前後空白・囲み " を除去
_raw="${SLACK_BOT_TOKEN:-${SLACK_TOKEN:-}}"
_raw="${_raw//$'\r'/}"
SLACK_TOKEN="${_raw#"${_raw%%[![:space:]]*}"}"
SLACK_TOKEN="${SLACK_TOKEN%"${SLACK_TOKEN##*[![:space:]]}"}"
if [[ "$SLACK_TOKEN" == \"*\" ]]; then
  SLACK_TOKEN="${SLACK_TOKEN#\"}"
  SLACK_TOKEN="${SLACK_TOKEN%\"}"
fi

SLACK_CHANNEL="${LIFE_REMINDER_SLACK_CHANNEL_ID:-C0ASQ7MTL7R}"
MENTION_ID="${LIFE_OWNER_SLACK_ID:-U0ARZH32TSQ}"

if [[ -z "$SLACK_TOKEN" ]]; then
  echo "$(date): missing SLACK_BOT_TOKEN or SLACK_TOKEN in $ENV_FILE" >&2
  exit 1
fi
# Bot トークン（xoxb-）のみ許可。xoxp- を使うと本人名投稿になるため禁止。
if [[ ! "$SLACK_TOKEN" =~ ^xoxb- ]]; then
  echo "$(date): SLACK_BOT_TOKEN は xoxb-（Bot token）で始まる値のみ使用できます" >&2
  exit 1
fi

case "$TYPE" in
  breakfast)
    TEXT="朝食！"
    ;;
  lunch)
    TEXT="12:00に昼飯！"
    ;;
  snack)
    TEXT="補食！！"
    ;;
  dinner)
    TEXT="18:30までに夜ご飯！！"
    ;;
  training)
    TEXT=$'トレーニング開始！\n今日を全力で追い込みましょう！'
    ;;
  work_end)
    TEXT="仕事は20時まで！ジムに向かう！！"
    ;;
  voice_journal)
    TEXT="今すぐ音声ジャーナル作成！"
    ;;
  bedtime)
    TEXT="ベッドに入ろう。夜更かし厳禁！"
    ;;
  *)
    echo "Usage: $0 <breakfast|lunch|snack|dinner|training|work_end|voice_journal|bedtime>" >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT_FROM_SCRIPT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

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
    CANDIDATE1="$VAULT_ROOT_FROM_SCRIPT/09_Athlete/10_トライアスロン/週間練習メニュー.md"
    CANDIDATE2="${GITHUB_WORKSPACE:-}/09_Athlete/10_トライアスロン/週間練習メニュー.md"
    if [[ -f "$CANDIDATE1" ]]; then
      MENU_FILE="$CANDIDATE1"
    elif [[ -n "${GITHUB_WORKSPACE:-}" && -f "$CANDIDATE2" ]]; then
      MENU_FILE="$CANDIDATE2"
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
    CANDIDATE1="$VAULT_ROOT_FROM_SCRIPT/09_Athlete/70_食事/食事リマインド本文.md"
    CANDIDATE2="${GITHUB_WORKSPACE:-}/09_Athlete/70_食事/食事リマインド本文.md"
    if [[ -f "$CANDIDATE1" ]]; then
      MEAL_FILE="$CANDIDATE1"
    elif [[ -n "${GITHUB_WORKSPACE:-}" && -f "$CANDIDATE2" ]]; then
      MEAL_FILE="$CANDIDATE2"
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
    --arg text "$TEXT" \
    --arg body "$MENU_BODY" \
'{
  "channel": $channel,
  "text": ("<@" + $mention + "> " + $text + "\n\n" + $body),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("<@" + $mention + "> " + $text)
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("*【週間メニュー】*\n\n" + $body)
      }
    }
  ]
}')
elif [[ "$TYPE" == "breakfast" || "$TYPE" == "lunch" || "$TYPE" == "snack" || "$TYPE" == "dinner" ]]; then
  PAYLOAD=$(jq -n \
    --arg channel "$SLACK_CHANNEL" \
    --arg mention "$MENTION_ID" \
    --arg text "$TEXT" \
    --arg body "$MEAL_BODY" \
'{
  "channel": $channel,
  "text": ("<@" + $mention + "> " + $text + "\n\n" + $body),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("<@" + $mention + "> " + $text)
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": $body
      }
    }
  ]
}')
elif [[ "$TYPE" == "voice_journal" ]]; then
  if [[ -n "${LIFE_VOICE_SLACK_LINK:-}" ]]; then
    PAYLOAD=$(jq -n \
      --arg channel "$SLACK_CHANNEL" \
      --arg mention "$MENTION_ID" \
      --arg text "$TEXT" \
      --arg vlink "$LIFE_VOICE_SLACK_LINK" \
'{
  "channel": $channel,
  "text": ("<@" + $mention + "> " + $text + "\n\n<" + $vlink + "|音声チャンネルへ>"),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("<@" + $mention + "> " + $text)
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("<" + $vlink + "|音声チャンネルへ>")
      }
    }
  ]
}')
  else
    PAYLOAD=$(jq -n \
      --arg channel "$SLACK_CHANNEL" \
      --arg mention "$MENTION_ID" \
      --arg text "$TEXT" \
'{
  "channel": $channel,
  "text": ("<@" + $mention + "> " + $text),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("<@" + $mention + "> " + $text)
      }
    }
  ]
}')
  fi
else
  PAYLOAD=$(jq -n \
    --arg channel "$SLACK_CHANNEL" \
    --arg mention "$MENTION_ID" \
    --arg text "$TEXT" \
'{
  "channel": $channel,
  "text": ("<@" + $mention + "> " + $text),
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("<@" + $mention + "> " + $text)
      }
    }
  ]
}')
fi

SLACK_RESPONSE=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$PAYLOAD")

# p1-1.env と同じ ~/.config/lifeos/ にログ（CI では親ディレクトリが無いことがある）
LOG_FILE="${HOME}/.config/lifeos/life-reminder.log"
mkdir -p "$(dirname "$LOG_FILE")"
if echo "$SLACK_RESPONSE" | jq -e '.ok == true' >/dev/null 2>&1; then
  echo "$(date): reminder sent [$TYPE]" >> "$LOG_FILE"
else
  ERROR_TEXT=$(echo "$SLACK_RESPONSE" | jq -r '.error // "unknown_error"' 2>/dev/null)
  echo "$(date): reminder failed [$TYPE] error=${ERROR_TEXT}" >> "$LOG_FILE"
  echo "$(date): Slack API error [$TYPE] ${SLACK_RESPONSE}" >&2
  exit 1
fi
