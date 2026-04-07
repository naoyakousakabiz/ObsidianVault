---
date: 2026-04-08
type: playbook
domain: ai
status: active
source: claude-code
generated_at: 2026-04-08
reviewed: false
tags:
  - google-apps-script
  - notebooklm
  - obsidian
---

# NotebookLM 用 GAS

## どこに何を入力するか（これだけ見ればよい）

**入力する場所は Google Apps Script の 1 ファイルだけです。**

1. ブラウザで [script.google.com](https://script.google.com) を開く  
2. この同期用の**プロジェクト**を開く  
3. 左のファイル一覧から **`コード.gs`** を開く（名前が違う場合はメインの .gs）  
4. 画面上部あたりの **`var CONFIG = {` で始まるブロック**を探す  

| キー（コードに書く名前） | 意味 | 貼るのは「元」？「先」？ |
|--------------------------|------|--------------------------|
| **`SYNC_FOLDER_ID`** | `.md` があるフォルダ（Vault 内の NotebookLM 用 MD フォルダ） | **元** |
| **`OUTPUT_ROOT_FOLDER_ID`** | 生成する **Google ドキュメント**を置くフォルダ | **先** |
| **`SOURCE_PARENT_FOLDER_ID`** | `SYNC_FOLDER_ID` を**空**にしたときだけ使う。MD フォルダの**ひとつ上**（例: Obsidian Vault フォルダ） | （経路用・実質は元の親） |
| **`SYNC_FOLDER_NAME`** | 上とセット。Drive の **MD フォルダの表示名**と完全一致 | 名前だけ（ID ではない） |

**おすすめ:** `SYNC_FOLDER_ID` に **元フォルダ**の URL から取った ID だけ入れる → `SOURCE_PARENT` は未使用のままでよい。

**フォルダ ID の取り方（元も先も同じ）:**

- そのフォルダを **Google Drive（ブラウザ）**で開く  
- アドレスが `https://drive.google.com/drive/folders/長い英数字` になる  
- **`folders/` の直後〜次の `?` まで**をコピーして、該当する `CONFIG` の `'...'` の中に貼る  

**注意:** Cursor / Obsidian の Vault にある `99_System/NotebookLM_Sync_Code.gs` を編集しただけでは **Google 上の GAS は更新されません。** 必ず **script.google.com の `コード.gs` に全文を貼り直すか、同じ `CONFIG` を手で合わせて保存**してください。

---

正本: `99_System/NotebookLM_Sync_Code.gs`（全文を Apps Script にコピー）

プレビュー: `![[NotebookLM_Sync_Code.gs]]`

## 旧 GAS から値を写す対応

| 昔の変数のイメージ | 今の `CONFIG` キー |
|--------------------|--------------------|
| MD 側の親フォルダ ID | `SOURCE_PARENT_FOLDER_ID`（`SYNC_FOLDER_ID` 空のとき） |
| MD フォルダを直指定していた ID | `SYNC_FOLDER_ID` |
| 出力ルートの ID | `OUTPUT_ROOT_FOLDER_ID` |

機微 ID はこのノート本文には書かない。
