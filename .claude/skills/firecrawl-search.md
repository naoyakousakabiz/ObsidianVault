---
id: firecrawl-search
version: 1
domains: [web-fetch, research]
requires: [Firecrawl MCP または CLI]
related: [firecrawl-scrape, firecrawl-map, firecrawl-crawl]
---

# /firecrawl-search — Web 検索と本文の取得

## これは何か

キーワードから**候補ページを探しつつ、本文の一部も**取り込むための入口です。「どの URL を読めばいいか」がまだ決まっていないときに向いています。

## いつ使うか

- 調べ物の最初で、信頼できそうな URL の**短いリスト**が欲しいとき
- 検索結果のスニペットだけでは足りず、**本文の根拠**も欲しいとき

## 使わないほうがよい場合

- URL がもう決まっている → `firecrawl-scrape`
- 1 サイトの全ページ感が欲しい → `firecrawl-map` や `firecrawl-crawl`

## 前提条件

- Firecrawl が使えること。**API キーはユーザー環境**に置く。

## どう依頼するか

1. **`firecrawl-search`** と、**一文で**調べたいこと（あいまい語は少なめに）。
2. 除きたいドメイン、必ず含めたいドメイン。
3. 欲しい件数の上限。

**例:** 「`firecrawl-search`。『Next.js App Router の middleware 変更 2024』公式寄りで 8 件。」

## 進め方（エージェント向け）

1. 目的と「URL はもう決まっているか」を確認する。
2. 検索で候補を集め、**どの URL から取ったか**を必ず示す。
3. 公式や一次情報を優先し、質の低いミラーは下げる。
4. 取れない理由は隠さず、無理な再試行はしない。

## 完了の目安

- 主な内容に**出典 URL**が付いている（取れなかったものは明示）
- 次に scrape や map へ進むか判断できる
- 規約・個人情報・レートを踏まえた範囲になっている

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
