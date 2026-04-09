---
id: firecrawl-browser
version: 1
domains: [web-fetch]
requires: [Firecrawl のブラウザ相当機能。認証はユーザー環境]
related: [firecrawl-scrape, firecrawl-agent, firecrawl-crawl]
---

# /firecrawl-browser — 画面操作や描画後の DOM が必要な取得

## これは何か

JavaScript で描画されるページや、ボタンを押したあとに出る内容など、**単純な scrape では足りない**ときの選択肢です。CAPTCHA 回避や規約違反はしません。

## いつ使うか

- SPA で、最初の HTML に本文がほとんどないとき
- 「もっと見る」のあとにだけ欲しいデータがあるとき

## 使わないほうがよい場合

- 静的 HTML で足りる → `firecrawl-scrape`
- URL が静的に揃う一覧だけ → scrape を複数回

## 前提条件

- Firecrawl のブラウザ機能。**ログイン情報は会話に書かない**（環境やプロファイル側）。

## どう依頼するか

1. **`firecrawl-browser`** と URL。
2. 人が画面でやる**操作の順番**を短く。
3. ログインが要るか（秘密は書かない）。

**例:** 「`firecrawl-browser`。`https://app.example.com/list`。**自分でセッションは用意済み**。フィルタで公開のみ→表示件数 100。」

## 進め方（エージェント向け）

1. まず scrape でダメな理由を短く言い、ブラウザが要る根拠を示す。
2. 操作は**最小限**。待つ条件とタイムアウトを書く。
3. 秘密をログに残さない。
4. ブロックされる可能性は正直に書く（成功率は保証しない）。

## 完了の目安

- 手順が**他人も再現できる**粒度
- 認証情報を**要求・記録していない**
- グレーな用途は**断っている**

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
