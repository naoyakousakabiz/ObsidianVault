---
date: 2026-04-08
type: playbook
domain: system
status: active
source: claude-code
generated_at: 2026-04-08
reviewed: false
tags:
  - vault-structure
---

# Vault フォルダ・ファイル設計一覧（現行）

**正本の位置づけ:** ルート [`CLAUDE.md`](../CLAUDE.md) の「Vaultフォルダ構成」と整合させる。**このノートは**ルート直下〜主要サブフォルダの**設計**と**命名規則**を一覧化する。

**実体の全ファイル一覧（スナップショット）:** 同フォルダの `vault_directory_tree_full.txt`（[`export_vault_tree.py`](scripts/export_vault_tree.py) で再生成）。

---

## 1. ルート直下（番号 = 設計上の固定順）

| パス | 役割 |
|:-----|:-----|
| `00_Inbox/` | 一時受信・整理前 |
| `01_Work/` | 本業実務・スキル・プレイブック（内向き） |
| `02_Business/` | 個人事業戦略。副業 RINGBELL は `02_Business/01_RINGBELL/` |
| `03_Career/` | キャリア・転職活動（外向き） |
| `04_AI/` | AI 戦略・ツール運用・学習の**正本** |
| `05_Life/` | 共同生活インフラ（健康・イベント・家計・契約・住居等） |
| `06_Child/` | 子ども関連 |
| `07_Asset/` | 所有物（服・靴・鞄・ガジェット等） |
| `08_Relationship/` | パートナー・家族・人脈・パターン |
| `09_Athlete/` | 競技・トレーニング・健康・睡眠・食事 |
| `10_Culture/` | 文化・教養・趣味系学習 |
| `11_Beauty/` | 美容・アンチエイジング |
| `20_Input/` | **外部インプット**（Kindle・クリッピング等／自動同期） |
| `80_Journal/` | 日次ログ・Voice |
| `98_NotebookLM_Sync/` | NotebookLM 向け**同期コピー**（**編集しない**） |
| `99_System/` | テンプレ・スクリプト・本ガイド・GAS メモ |
| `12_`〜`19_` | **未使用（将来拡張予約）** |

**ツール・エディタ領域（設計対象外だが同梱）:** `.obsidian/` `.cursor/` `.claude/` `.vscode/`  
**ごみ箱:** `.trash/`（削除済みノート）

---

## 2. 主要サブフォルダ（現行構成）

### `01_Work/`

| パス | 用途 |
|:-----|:-----|
| `10_スキル/` | スキルマップ・職能別（`10_共通スキル/` `20_CS業務/` `30_営業/` 等） |
| `20_業務手順/` | 業務フロー・`20_プロセス/` `30_テンプレート/` |
| `30_プロジェクト/` | 本業プロジェクト |
| `40_組織運営/` | マネジメント系 |
| `50_業務自動化/` | 本業ドメインの自動化設計 |
| `80_メモ/` | 作業メモ |
| `CLAUDE.md` `README.md` | フォルダコンテキスト |

### `02_Business/`

| パス | 用途 |
|:-----|:-----|
| `01_RINGBELL/` | 副業（婚活 CS）の索引・業務設計・`50_業務自動化/`（棚: `00_`〜`30_` は `50_業務自動化/00_AI自動化_フォルダ設計.md`） |
| `00_strategy.md` | 事業戦略メモ |
| `CLAUDE.md` `README.md` | コンテキスト |

### `03_Career/`

| パス | 用途 |
|:-----|:-----|
| `10_プロフィール/` | 職務要約・経歴・特性 |
| `20_マスタ/` | マスター文書 |
| `30_キャリア戦略/` | 戦略・計画・`30_synthesis/` |
| `40_転職活動/` | キャンペーン・企業フォルダ・`99_アーカイブ/` |
| `50_自動化/` | スクリプト・手順 |
| `00_README.md` `CLAUDE.md` | コンテキスト |

### `04_AI/`

| パス | 用途 |
|:-----|:-----|
| `01_運用/` | 索引・ツール役割・NotebookLM・運用ルール・データ蓄積 |
| `04_テンプレート/` | AI 導入コンサル向け**テンプレ正本**（`00`メタ・`01`司令塔・`02`マスター・`03`Executive） |
| `02_手法/` | 手法メモ（**`ツール_作業内容.md`** 形式）。読書・ファクトチェック・MCP・NotebookLM・Claude Code 等 |
| `03_学習/` | 講座・参照メモ（**`ClaudeCode_`／`AI_`／`Obsidian_`＋内容.md** など）。**`今後やること.md`（実行ハブ）** は固定名 |
| `05_SNSノウハウ/` | note・X 等 **SNS／コンテンツ配信**の型・検証メモ（`note_` など） |
| `80_実験ログ/` | 短期実験・宿題 |
| `99_アーカイブ/` | 旧版・退避 |
| `README.md` `CLAUDE.md` | 正本リンクは `README.md` に集約 |

### `05_Life/`

| パス | 用途 |
|:-----|:-----|
| `11_health/` | 健康リマインド・測定 |
| `20_events/` | ライフイベント（日付 or TBD プレフィックス） |
| `30_finance/` | 研究・FP・生活費・サブスク |
| `40_agreements/` | 契約・住戦略・同居ルール・外注・防災 |
| `50_housing/` | 住居 |
| `60_insurance/` | 保険 |
| `70_decisions/` | 意思決定ログ |
| `80_documents/` | 文書索引等 |
| `99_archive/` | アーカイブ |
| `README.md` `CLAUDE.md` | コンテキスト |

### `08_Relationship/`

| パス | 用途 |
|:-----|:-----|
| `10_partner/` | パートナー記録・記念日・プロフィール・価値観 |
| `20_family/` | 家族・実家 |
| `30_network/` | 人脈 |
| `40_friends/` | 友人 |
| `50_patterns/` | コミュニケーションパターン |
| `CLAUDE.md` `README.md` | コンテキスト |

### `09_Athlete/`

| パス | 用途 |
|:-----|:-----|
| `10_トライアスロン/` `20_登山/` `30_筋トレ/` `40_運動/` | 種目別 |
| `50_健康/` `60_睡眠/` `70_食事/` | condition・ログ系 |
| `CLAUDE.md` | コンテキスト |

### `20_Input/`

| パス | 用途 |
|:-----|:-----|
| `01_Kindle/` | 読書ハイライト同期・`_processed_log.md` |
| `02_Clippings/` | Web クリッピング・`_processed_log.md` |
| `03_RSS/` | RSS 取り込みの受け皿・`_購読リスト.md`・`CLAUDE.md`（設計は `04_AI/03_学習/10_リサーチ/ObsidianRSS_LINE取り込み設計.md`） |
| `04_LINE/` | 個人 LINE から逃がした断片の受け皿・`CLAUDE.md`（業務公式 LINE は対象外） |

### `80_Journal/`

| パス | 用途 |
|:-----|:-----|
| `01_Daily/` | `YYYY-MM-DD.md` |
| `02_Voice/` | `YYYY-MM-DD.m4a`（推奨名） |
| `CLAUDE.md` | Voice 運用・デイリー参照 |

### `98_NotebookLM_Sync/`

- **編集禁止**（GAS が上書き）。正本は対応表どおりの Vault 側（例: `04_Asset` 相当 → `07_Asset/`）。
- **対応表:** `98_NotebookLM_Sync/00_index.md`

### `99_System/`

| パス | 用途 |
|:-----|:-----|
| `Templates/` | Daily・会議・読書等テンプレ |
| `scripts/` | `export_vault_tree.py`・`rename_voice_m4a.py` 等 |
| `01_NotebookLM_GAS_同期スクリプト.md` | GAS 運用メモ |
| `NotebookLM_Sync_Code.gs` | GAS 正本（Apps Script へコピー） |
| `vault_directory_tree_full.txt` | 全ファイルツリー（自動生成） |

---

## 3. ファイル設計（命名・種別）

| 種別 | 規則 | 例 |
|:-----|:-----|:-----|
| イベント・ログ系 | `YYYYMMDD_名前.md` | `20260613_引越し.md` |
| インデックス・設計 | `NN_名前.md` | `00_索引.md` |
| 処理ログ | `_processed_log.md` | Kindle / Clippings 配下 |
| デイリー | `80_Journal/01_Daily/YYYY-MM-DD.md` | 日付はハイフン |
| Voice | `80_Journal/02_Voice/YYYY-MM-DD.m4a` | 同日2本目は `_001` 等 |

**フロントマター:** 新規ノートはルート [`CLAUDE.md`](../CLAUDE.md) の「ファイルフロントマター規約」に従う（`date` `type` `domain` `status` `source` `tags`）。

---

## 4. よくある混同

| 注意点 | 正しい解釈 |
|:--|:--|
| NotebookLM の冊名「02 Business」と Obsidian の `02_Business/` | **別系統のラベル**（詳細 `04_AI/01_運用/03_NotebookLM.md`） |
| `98_NotebookLM_Sync/04_Asset/` と `07_Asset/` | **98 は同期ミラー**。編集は `07_Asset/` 側（対応は `00_index.md`） |
| `Vault_Structure_Guide.md` の旧版 | **00〜99 の現行番号体系**が正。旧 `10_Ideas` / `40_Knowledge` 等の記述は**廃止済み** |

---

## 5. メンテナンス

- **構造を変えたら:** 本書の表を更新し、必要ならルート `CLAUDE.md` のツリーも同期する。
- **全ファイルを洗い出したいとき:** Vault ルートで `python3 99_System/scripts/export_vault_tree.py`
