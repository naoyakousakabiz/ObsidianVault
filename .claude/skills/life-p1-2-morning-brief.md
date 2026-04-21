---
id: life-p1-2-morning-brief
version: 1
domains: [life, productivity]
requires: [Google Calendar MCP, Slack MCP]
related: [life-p1-1-collect]
---

# life-p1-2-morning-brief — 朝ブリーフ

## これは何か

毎朝 07:00 に Google Calendar と Daily の優先タスクを統合し、
`#life-briefing` へ配信する自動化スキル。

## 実行手順

1. **Google Calendar** から今日の予定を取得
   - `gcal_list_events`（timeMin: 今日 00:00 JST, timeMax: 今日 23:59 JST）
   
2. **今日のDailyノート** の「今日やること」セクションを読む
   - `80_Journal/01_Daily/YYYY-MM-DD.md`（なければスキップ）

3. **ブリーフを作成**（以下のフォーマット）

Slack メッセージ（Slack markdown形式）:
```
📅 *朝ブリーフ [YYYY-MM-DD]* <@U0ARZH32TSQ>

*📆 今日の予定*
[カレンダーイベント一覧、なければ「予定なし」]

*✅ 今日の優先タスク*
[RINGBELL / 転職 / トレーニング / その他 横断で全件]
```

4. **Slack 送信**
   - チャンネル: `C0ATZUU36RE`（#life-briefing, workspace: test-qno9331.slack.com）
   - 上記フォーマットで送信（`<@U0ARZH32TSQ>` メンション必須）

~~5. メール送信~~ — **廃止（2026-04-16）。Slack + Daily のみで運用。**

## 失敗時

`05_Life/50_AI自動化/90_運用ログ/YYYY-MM-DD_automation-error.md` にログ記録。
task_id: `p1-2-morning-brief-0700`

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
