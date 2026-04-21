---
date: YYYY-MM-DD
type: log
domain: life
status: active
source: claude-code
tags: [automation, error-log]
---

# 自動化エラーログ: YYYY-MM-DD

## エラー記録

| 項目 | 内容 |
|---|---|
| timestamp | YYYY-MM-DD HH:MM JST |
| task_id | （例: meal-training-weekday-1930） |
| error_summary | （エラーの概要） |
| fallback_action | （取った手動対応） |
| status | failed / resolved |

## フォールバック手順

1. Slack通知が来ない場合 → `80_Journal/01_Daily/YYYY-MM-DD.md` を直接確認
2. Daily追記が失敗した場合 → 手動でDaily末尾にメモを追加
3. 連続3日以上失敗した場合 → 新機能追加を停止し、安定化を優先

## 解決メモ

（解決した場合は手順・原因を記録する）
