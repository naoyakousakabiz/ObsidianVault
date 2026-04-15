---
id: typefully-schedule
version: 1
domains: [content, sns, automation]
requires:
  - Typefully API キー（Bearer）。PUBLISH 権限（予約・即時公開に必要）
  - social_set_id（数値）。未設定なら GET /v2/social-sets で特定
related: [x-post-draft]
---

# /typefully-schedule — Typefully API で X 投稿を予約

## これは何か

**決めた本文**を Typefully 経由で **指定日時に公開予約**する。  
API は **Create draft**（`POST /v2/social-sets/{social_set_id}/drafts`）に `publish_at` を渡してスケジュールする。

公式: `https://api.typefully.com`・ドキュメント `https://typefully.com/docs/api`（参照時点で v2）。

## いつ使うか

- `/x-post-draft` などで出した案のうち **1本を選び、「明日 9:00 JST」など具体時刻に載せたい**とき
- n8n なしで **curl / スクリプトから1回予約**したいとき

## 使わないほうがよい場合

- Typefully 未契約・API キーなし（402 等になる）
- **複数パターンを3本まとめて予約**だけが目的 → Typefully 上で下書き分けるか、API を3回呼ぶ
- X の自動投稿ポリシー・利用規約の確認をしていない（アカウントリスク）

## 前提条件

1. **API キー:** Typefully 設定から発行。**チャットや Vault に平文で貼らない。** 環境変数例: `TYPEFULLY_API_KEY`
2. **social_set_id:** 例 `TYPEFULLY_SOCIAL_SET_ID=12345`。不明なら:

   ```bash
   curl -sS -H "Authorization: Bearer $TYPEFULLY_API_KEY" \
     "https://api.typefully.com/v2/social-sets?limit=25"
   ```

3. **`publish_at`:** **タイムゾーン付き ISO 8601**（公式例: `'2025-01-20T09:00:00-05:00'`）。**「明日 9 時」は曖昧なので必ず TZ を確定**する（既定は **Asia/Tokyo** でよいとユーザーに確認）。

## 依頼例

- 「`typefully-schedule`。本文は「……」。**明日 9:00 JST**。`social_set_id` は環境変数。」
- 「`x-post-draft` の **案2** を Typefully に **2026-04-12 09:00 +09:00** で予約。」

## 進め方（エージェント）

1. **本文**を確定（140字要件は X 側。ハッシュタグを本文に含めるかはユーザー確認）。
2. **`publish_at` を生成**（例: 翌日 9:00 JST）:

   ```bash
   python3 -c "from datetime import datetime, timedelta; from zoneinfo import ZoneInfo; z=ZoneInfo('Asia/Tokyo'); d=datetime.now(z).date()+timedelta(days=1); print(datetime(d.year,d.month,d.day,9,0,tzinfo=z).isoformat())"
   ```

3. **リクエストボディ**（**X のみ**予約したい典型形。他 SNS が同じ social set にぶら下がっている場合、Typefully 上の接続と API の挙動を確認し、必要なら他プラットフォームは `enabled: false` で明示）:

   ```json
   {
     "platforms": {
       "x": {
         "enabled": true,
         "posts": [{ "text": "ここに投稿本文" }],
         "settings": { "share_with_followers": true }
       }
     },
     "draft_title": "API予約（内部用タイトル）",
     "publish_at": "2026-04-12T09:00:00+09:00"
   }
   ```

4. **実行**（ドライランなしで実リクエストになるので、実行前にユーザーへ **時刻・本文・social_set** を一行で確認）:

   ```bash
   curl -sS -X POST \
     "https://api.typefully.com/v2/social-sets/${TYPEFULLY_SOCIAL_SET_ID}/drafts" \
     -H "Authorization: Bearer ${TYPEFULLY_API_KEY}" \
     -H "Content-Type: application/json" \
     -d @payload.json
   ```

5. 応答の `status: scheduled`・`scheduled_date`・`private_url` をユーザーに返す。4xx/5xx は本文を要約（**API キーを伏せる**）。

## 成果物（表）

| # | 成果物 | 形式 |
|---|--------|------|
| 1 | 予約済み下書き / スケジュール | Typefully 上の draft（`status` が `scheduled` 等） |
| 2 | 確認用 URL | 応答の `private_url`（あれば） |

## 完了の目安

- `publish_at` が **タイムゾーン付き**でユーザーの意図と一致
- **本番 POST 前**にユーザーが時刻・本文を確認済み
- 秘密（API キー）をログ・チャットに残していない

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
