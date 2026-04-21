---
id: life-p1-1-collect
version: 1
domains: [life, input]
requires: [RSS/Web取得, YouTube RSS, X MCP（APIキー取得後）, Slack MCP, Obsidian保存]
related: [life-p1-2-morning-brief]
---

# life-p1-1-collect — 情報収集自動化

## これは何か

毎朝 06:32 に RSS・YouTube・X から新着情報を収集し、
朝ブリーフ用の要点を `20_Input/05_日次情報収集/` に保存する自動化スキル。
実行基盤: ローカルMac（launchd）+ `~/scripts/p1-1-collect.sh`

## 実行手順

### 1. RSSフィード取得（過去24時間以内の新着）

| フィード | URL |
|---|---|
| AGIラボ | `https://note.com/chatgpt_lab/rss` |
| ITmedia AI+ | `https://rss.itmedia.co.jp/rss/2.0/aiplus.xml` |
| Zenn AI | `https://zenn.dev/topics/ai/feed` |
| 日経クロステック | `https://xtech.nikkei.com/rss/index.rdf` |

### 2. YouTube新着取得（過去24時間以内）

以下のハンドルから channel_id を取得し、RSS（`https://www.youtube.com/feeds/videos.xml?channel_id=<ID>`）で新着を取得:

- AI活用: `@keitoaiweb` / `@chaen-ai-lab` / `@genAI-topic` / `@ai-advisor-channel`
- ファッション: `@MB-kk3hx` / `@stylist.ShunOyama`
- SaaSキャリア: `@ALLSTARSAASFUND`
- 旅: `@maibaru`
- モチベーション: `@makinotomoaki` / `@MorioRoutine`
- トライアスロン: `@hiro_triathlon`
- 教養/本要約: `@ferumi` / `@suasi_shacho`

### 3. X（Twitter）収集 ✅ 有効

- 対象アカウント: 25件（`11_日常AI自動化_実装指示書.md` §7.2A 参照）
- 条件: 本人投稿のみ（RT除外）・likes >= 100 ・AI関連キーワード含む
- 手段: X MCP（`x-mcp`、`Infatoshi/x-mcp` ベース）+ X API v2
- MCPツール: `search_recent_tweets` または `get_user_tweets` を使用
- 取得後、タイトル・URL・likes数を抽出して他ソースと同じフォーマットで保存

### 4. フィルタ・処理

- 重複排除: 同一URLは24時間以内に再収集しない
- 優先キーワード: `Claude` / `ChatGPT` / `Gemini` / `Cursor` / `MCP` / `AIエージェント` / `自動化` / `ワークフロー`
- 言語: 日本語+英語（要約は日本語）

### 5. 保存

- ファイル: `20_Input/05_日次情報収集/YYYY-MM-DD_collect.md`
- フォーマット: タイトル / URL / 1行要約（日本語）

### 6. 通知

- Slack `C0ATZUU36RE`（#life-briefing）に「📥 収集完了 [日付]: N件」を送信（`<@U0ARZH32TSQ>` メンション付き）

## 失敗時

`05_Life/50_AI自動化/90_運用ログ/YYYY-MM-DD_automation-error.md` にログ記録。
task_id: `p1-1-collect-0630`

## 実装ステータス

| 機能 | 状態 |
|---|---|
| RSS収集 | ✅ 実装可能 |
| YouTube収集 | ✅ 実装可能 |
| X収集 | ✅ 有効（x-mcp 設定済み） |

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
