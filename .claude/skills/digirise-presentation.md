---
id: digirise-presentation
version: 1
domains: [design, document]
requires: [python-pptx 等、またはテンプレpptx。ストーリーライン]
related: [digirise-proposal, generate-proposal-excel]
---

# /digirise-presentation — スライド（構成から pptx）

## これは何か

ストーリーとブランドの制約から**スライドの中身**を表で固め、`python-pptx` などで **`.pptx` に落とす手順やスクリプト案**を出します。**仕上げの最終判断は人間**に任せる前提です。

## いつ使うか

- 提案や登壇資料を、**骨子からファイル**まで短時間で進めたいとき
- マスタースライドに沿って、**形式的にそろえたい**とき

## 使わないほうがよい場合

- ブラウザで見せるダッシュボードが主 → `digirise-proposal`
- 数値だらけの 11 シート提案書が主 → `generate-proposal-excel`

## 前提条件

- Python と `python-pptx` などが使えるか、または「設計書だけ」モードかを決める。

## どう依頼するか

1. **`digirise-presentation`** と、目次レベルの流れ・枚数目安。
2. 色・フォント・ロゴの扱い。既存テンプレのパス。
3. 機密はダミーでよいか。

**例:** 「`digirise-presentation`。提案 15 枚。テンプレは `~/templates/pitch.pptx`。主色 #112233。顧客名はダミー。」

## 進め方（エージェント向け）

1. スライドごとにタイトル・箇条書き・図の種類を表にする。
2. 実装するならマスターとプレースホルダ ID の扱いをはっきり書く。
3. 仕上げチェック（はみ出し・フォント埋め込み）を短く列挙する。
4. 機密はダミーに置き換える。

## 完了の目安

- 表が**そのまま実装や手作業の指示**に使える
- ブランド指定が**色コードなど具体**になっている
- 社外配布前に**人がレビューする**前提が書いてある

**共通ルール:** [00_shared-governance.md](./00_shared-governance.md)
