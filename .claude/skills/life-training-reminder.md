---
id: life-training-reminder
version: 1
domains: [life, athlete]
requires: [Slack MCP (mcp__claude_ai_Slack__slack_send_message)]
related: [life-meal-reminder]
---

# life-training-reminder — トレーニング定時通知

## これは何か

週次トレーニングスケジュールに基づき、練習開始前・終了後に `#life-reminder` へ通知する自動化スキル。
CronCreate で定時実行される。

## 週次メニュー（毎週固定・ロングラン毎週）

| 曜日 | メニュー |
|---|---|
| 月 | Swim 2km（Z2・ドリル含む） |
| 火 | Run 10km Z2（6:10〜6:30/km・HR130〜145bpm） |
| 水 | Swim 2km（インターバル Z3〜Z4） |
| 木 | 筋トレ60分（ウェイト＋体幹・股関節） |
| 金 | Swim 1.5km（Z2軽め） |
| 土 | Run 25〜32km |
| 日（第1） | 自主OD |
| 日（第2〜） | 完全OFF（通知なし） |

## 通知スケジュール

| 曜日 | 開始通知 | 終了通知 |
|---|---|---|
| 平日（月〜金） | 19:30 | 22:00 |
| 土曜 | 06:30 | 13:00 |
| 第1日曜 | 08:30 | 11:00 |
| その他の日曜 | なし | なし |

## 平日 19:30 は夕食通知と統合

平日の19:30通知は `life-meal-reminder` の夕食と統合して1通知にまとめる。

## Slack設定

- チャンネル: `#life-reminder`（channel_id: `C0ASQ7MTL7R`）
- ワークスペース: `test-qno9331.slack.com`
- メンション: `<@U0ARZH32TSQ>`（nao）

## 失敗時

`05_Life/50_AI自動化/90_運用ログ/YYYY-MM-DD_automation-error.md` にログを記録。
task_id は `training-[start/end]-[曜日]-[HHMM]` 形式。

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
