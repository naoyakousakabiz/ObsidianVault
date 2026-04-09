---
id: firecrawl-download
version: 1
domains: [web-fetch, filesystem]
requires: [Firecrawl MCP または CLI。十分なディスク容量]
related: [firecrawl-crawl, firecrawl-map, firecrawl-scrape]
---

# /firecrawl-download — ローカルへの保存・退避

## これは何か

取得した内容を**ローカルのファイル群**としてそろえます。オフラインで読む用、公開サイトの**自分用の控え**など（**再配布の権利はユーザーが確認**）。

## いつ使うか

- 公式ドキュメントを開発機に**オフラインで置きたい**とき
- crawl の結果を、いったん**ディスクに置いてから**後処理したいとき

## 使わないほうがよい場合

- 数ページだけ → **scrape を数回**の方が単純なことが多い
- 再配布や公開が目的で、ライセンスが未確認

## 前提条件

- Firecrawl と十分な空き容量。件数は**map 等で先に見積もり**するとよい。

## どう依頼するか

1. **`firecrawl-download`** と起点 URL、保存先の考え方（パス）。
2. 含める／除くパス。**容量の上限**。
3. 1 ファイルにまとめるか、ページ別か。

**例:** 「`firecrawl-download`。`https://docs.example.com/api/` だけを `./mirror/` に。最大 500MB。」

## 進め方（エージェント向け）

1. 件数・容量・時間を見積もり、**ユーザーと合意**する。
2. URL をフラットなファイル名にする**規則**を決める。
3. `index.jsonl` などで**元 URL を紐づける**。
4. 再配布禁止の内容を混ぜないよう警告する。

## 完了の目安

- **マニフェスト**でトレースできる
- 上限が文章で固定されている
- 権利と社内ポリシーは**ユーザー確認**と書いてある

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
