---
id: life-meal-reminder
version: 1
domains: [life, health]
requires: [Slack MCP (mcp__claude_ai_Slack__slack_send_message)]
related: [life-training-reminder, life-p1-2-morning-brief]
---

# life-meal-reminder — 食事定時通知

## これは何か

毎日の食事タイミングを `#life-reminder` に通知する自動化スキル。
CronCreate で定時実行される。

## 通知スケジュール

| 時刻 | 内容 | メッセージ |
|---|---|---|
| 06:00 | 朝食 | 🍳 朝食の時間です（プロテイン P30） |
| 12:00 | 昼食 | 🥗 昼食の時間です（定食 700kcal・P30） |
| 16:00 | 補食 | 💊 補食の時間です（プロテイン P30） |
| 19:30 | 夕食（週末） | 🍽️ 夕食の時間です（プロテイン P30） |
| 19:30 | 夕食+トレ開始（平日） | life-training-reminder と統合通知 |

## Slack設定

- チャンネル: `#life-reminder`（channel_id: `C0ASQ7MTL7R`）
- ワークスペース: `test-qno9331.slack.com`
- メンション: `<@U0ARZH32TSQ>`（nao）

## 失敗時

`05_Life/50_AI自動化/90_運用ログ/YYYY-MM-DD_automation-error.md` にログを記録。
task_id は `meal-[種別]-[HHMM]` 形式。

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
