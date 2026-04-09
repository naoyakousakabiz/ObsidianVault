---
id: digirise-proposal
version: 1
domains: [engineering, proposal]
requires: [Node.js・Vite／React／Tailwind。要件の文章]
related: [digirise-presentation, generate-proposal-excel]
---

# /digirise-proposal — 提案ダッシュボード（Web）

## これは何か

提案内容を **Vite ＋ React ＋ Tailwind** の軽いダッシュボードとして組むときの、構成と実装の進め方です。**誰が見られるか（ローカルだけか、VPN か）**と**機密**を最初に決めます。

## いつ使うか

- PDF だけだと更新が重いが、**スクロールで説明**したいとき
- 社内や VPN 内で、**軽くインタラクティブ**に見せたいとき

## 使わないほうがよい場合

- 印刷・メール送付が主でスライドで足りる → `digirise-presentation`
- 表計算中心の提案書 → `generate-proposal-excel`

## 前提条件

- Node とフロントの開発環境が用意できること。

## どう依頼するか

1. **`digirise-proposal`** とセクション構成（課題・施策・費用・スケジュールなど）。
2. まず仕様だけか、プロジェクトを作るか。**公開の範囲**。
3. 機密はダミーにするか。

**例:** 「`digirise-proposal`。`npm run dev` でローカルのみ。課題 3・施策 4・費用表。数値は全部ダミー。」

## 進め方（エージェント向け）

1. セクションとルーティング、状態管理が要るか決める。
2. 本文は **JSON や MD** に逃がし、コンポーネントは薄く保つ。
3. 本番 URL を勝手に想定しない。**認証・VPN** の確認リストを付ける。
4. 秘密は環境変数かローカル JSON に限定する。

## 完了の目安

- **誰がどこから見る想定か**が文章である
- データと見た目の**境界**がはっきりしている
- 確定価格・契約は**人間が確認**と書いてある

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
