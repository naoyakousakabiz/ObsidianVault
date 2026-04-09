---
id: firecrawl-agent
version: 1
domains: [web-fetch, data]
requires: [Firecrawl の構造化抽出が使える環境]
related: [firecrawl-scrape, firecrawl-crawl, firecrawl-browser]
---

# /firecrawl-agent — JSON など決めた型への抽出

## これは何か

ページの内容を、あらかじめ決めた**スキーマ（JSON）**に落とし込みます。イベント一覧や商品一覧のように、**横並びのデータ**が欲しいとき向けです。

## いつ使うか

- 一覧ページから**表形式のデータ**を抜きたいとき
- あとで Sheets や DB に流す**ETL の入口**にしたいとき

## 使わないほうがよい場合

- プレーンな要約だけで足りる → `firecrawl-scrape`
- クリック後にしか出てこない、JS 前提 → `firecrawl-browser` を検討

## 前提条件

- Firecrawl の agent や構造化抽出が使えるプランであること。

## どう依頼するか

1. **`firecrawl-agent`** と URL、または search のクエリ。
2. **JSON の形**（スキーマ）か、ダミーの 1 件例。
3. 欠損を null でよいか、推測を許すか。

**例:** 「`firecrawl-agent`。一覧 URL から `{ title, date, url }[]`。日付不明は null。」

## 進め方（エージェント向け）

1. スキーマと必須キーを固定する。
2. パースに失敗したら**生テキストを別フィールド**に逃がす案を検討する。
3. 各行に**出典 URL と取得時刻**を付ける。
4. 推測値は信頼度や注記を付ける（ルールで許す場合だけ）。

## 完了の目安

- スキーマに**矛盾なく**入る（サンプルは人が確認推奨）
- 出典が**辿れる**
- 個人情報を余計なフィールドに入れていない

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
