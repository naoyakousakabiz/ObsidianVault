---
id: firecrawl-crawl
version: 1
domains: [web-fetch]
requires: [Firecrawl MCP または CLI]
related: [firecrawl-map, firecrawl-scrape, firecrawl-search]
---

# /firecrawl-crawl — サイトを広くまとめて取得

## これは何か

**たくさんのページ**をまとめて取り込みます。オフラインメモリや RAG 用コーパスなど。**許可する範囲・最大ページ数・時間**は先に決めます。

## いつ使うか

- 公開されているドキュメントを**一式テキスト化**したいとき（権利はユーザーが確認）
- map で全体像を見たあと、**本番の取得**に進むとき

## 使わないほうがよい場合

- URL が少数だけ → **複数回 scrape** の方が安いことが多い
- まだ何を読むか決まっていない → `firecrawl-search`

## 前提条件

- Firecrawl と API のコスト、保存先のディスクに余裕があること。

## どう依頼するか

1. **`firecrawl-crawl`** と**許可するパスの範囲**（プレフィックス）。
2. **最大ページ数・深さ・時間**の上限。
3. 1 ファイルにまとめるか、ページごとに分けるか。

**例:** 「`firecrawl-crawl`。`https://docs.example.com/api/` のみ。最大 200 ページ。ファイルはページ別。」

## 進め方（エージェント向け）

1. map か少数 scrape で**試し取り**し、件数を推定する。
2. `admin` やセッションだらけの URL は除外パターンに入れる。
3. 失敗 URL の再試行回数を決める。
4. 利用規約・著作権に反する取得はしない。

## 完了の目安

- **上限と理由**が説明できる
- URL 一覧の**マニフェスト**を残す設計になっている
- 個人情報や会員限定ページを含めていない

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
