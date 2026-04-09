---
id: firecrawl-map
version: 1
domains: [web-fetch]
requires: [Firecrawl MCP または CLI]
related: [firecrawl-scrape, firecrawl-crawl, firecrawl-search]
---

# /firecrawl-map — サイト内の URL 一覧

## これは何か

起点の URL から、**そのサイト内でたどれる URL の一覧**を出します。いきなり広く crawl する前に、**件数や範囲の感触**を掴むのに向いています。

## いつ使うか

- ドキュメントサイト全体の**目次代わり**が欲しいとき
- crawl する前に、**パスでフィルタ**したいとき

## 使わないほうがよい場合

- 1 ページだけ → `firecrawl-scrape`
- まず検索で世界を当たりたい → `firecrawl-search`

## 前提条件

- Firecrawl が使えること。

## どう依頼するか

1. **`firecrawl-map`** と起点 URL またはドメイン。
2. 含めたい／除きたい**パスの先頭**。
3. おおまかな件数のイメージ（数十、数百など）。

**例:** 「`firecrawl-map`。`https://docs.example.com/` 起点。`/blog/` は除く。数百件想定。」

## 進め方（エージェント向け）

1. サブドメインを含めるか、深さの考え方をユーザーと合わせる。
2. 重複を除き、重要そうなパスには短いコメントを付けてもよい。
3. 巨大サイトでは**サンプリング**を提案する。
4. robots の制限に触れそうなら警告する。

## 完了の目安

- **フィルタ条件**が文章で残っている
- このあと scrape か crawl か**次の一手**が決められる
- 管理画面の URL を誤って含めていない

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
