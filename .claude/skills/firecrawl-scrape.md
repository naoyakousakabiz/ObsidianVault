---
id: firecrawl-scrape
version: 1
domains: [web-fetch]
requires: [Firecrawl MCP または CLI]
related: [firecrawl-search, firecrawl-map, firecrawl-crawl]
---

# /firecrawl-scrape — 1 ページを本文として取り込む

## これは何か

**URL が決まっている 1 ページ**から本文を取り、Markdown など読みやすい形に整えます。サイト全体の横断はしません。

## いつ使うか

- 公式ドキュメントの 1 本を要約や引用の材料にするとき
- LLM に渡す用に、**ノイズの少ないテキスト**が欲しいとき

## 使わないほうがよい場合

- まず検索で候補を探したい → `firecrawl-search`
- 同じドメインの**大量のページ** → `firecrawl-map` / `firecrawl-crawl`

## 前提条件

- Firecrawl が使えること。

## どう依頼するか

1. **`firecrawl-scrape`** と URL（複数なら少数に）。
2. 出力形式（Markdown など）。ログインが要るページかどうか。

**例:** 「`firecrawl-scrape`。`https://example.com/docs/install` を Markdown。タイトルと日付も。」

## 進め方（エージェント向け）

1. 静的ページか動的ページかの見立てをする。単純取得で失敗するなら browser の検討を添える。
2. タイトルや更新日が取れれば残す。
3. 失敗時は HTTP やブロックの理由を短く書く。

## 完了の目安

- **出典 URL と取得日**が付く（可能なら）
- 1 本の読みやすい本文になっている
- 認証ページを無理に突破しない

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
