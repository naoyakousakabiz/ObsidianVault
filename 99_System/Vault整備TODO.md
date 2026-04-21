---
date: 2026-04-07
type: log
domain: ai
status: active
source: claude-code
generated_at: 2026-04-07
reviewed: false
tags: [TODO, Vault整備]
---

# Vault整備TODO

フォルダ構造再設計後の残作業・確認事項リスト。

---

## ステータス凡例
- [ ] 未着手
- [/] 進行中
- [x] 完了

---

## 要確認・残作業

### 連携確認（手動で要確認）

- [ ] **Kindleプラグイン同期確認**
  - Obsidianを開き、左サイドバーの「Kindle」アイコンから手動同期を実行
  - `20_Input/01_Kindle/` にファイルが入るか確認
  - 保存先フォルダがリネーム後のパスになっているか設定確認
  - 設定場所：設定 → コミュニティプラグイン → Kindle Highlights → Folder

- [ ] **Obsidian Web Clipper確認**
  - `20_Input/02_Clippings/` に保存されているか確認
  - ブラウザ拡張の保存先設定を新パスに更新
  - 設定場所：Obsidian Web Clipper 拡張 → デフォルト保存先

- [ ] **NotebookLM_Sync 確認**
  - `98_NotebookLM_Sync/` 配下のサブフォルダ（`07_Asset`, `09_Athlete`）は旧フォルダ名のまま
  - NotebookLMとの同期設定に影響がないか確認
  - 影響ある場合はサブフォルダ名も変更が必要

- [ ] **obsidian-git 自動Push確認**
  - `git log origin/main --oneline -3` を実行してPushされているか確認
  - コマンド：`! git log origin/main --oneline -3`
  - 設定場所：設定 → コミュニティプラグイン → Obsidian Git → Auto push

### Vault内部リンク修正

- [x] **既存ファイルの内部リンク確認・修正（2026-04-07 Claude Code実施）**
  - 全mdファイルの旧パス参照を一括置換（91ファイル）
  - 残存する旧パス: 0件

- [x] **CLAUDE.md の内部参照パス更新（2026-04-07 Claude Code実施）**
  - 正本ファイルパスを新体系（`04_AI/01_運用/`）に更新済み

### ファイル名の日本語統一

- [x] フォルダ名の英語表記を日本語に統一（2026-04-07 Claude Code実施）
  - `01_Work/` 配下: 10_スキル, 20_業務手順, 30_プロジェクト, 40_組織運営, 80_メモ
  - `03_Career/` 配下: 10_プロフィール, 20_マスタ, 30_キャリア戦略, 40_転職活動, 50_自動化
  - `04_AI/` 配下: 01_ツール運用, 03_手法, 04_学習, 80_実験ログ, 99_アーカイブ
  - シェルスクリプト内パスも更新済み

### 初期データ入力（優先度高）

- [ ] 職務経歴書マスタ作成（`03_Career/10_プロフィール/01_職務経歴書マスタ.md`）
- [ ] 年収推移入力（`05_Life/30_finance/05_年収推移.md`）
- [ ] 保険一覧入力（`05_Life/60_insurance/01_保険一覧.md`）
- [ ] 資産管理入力（`05_Life/30_finance/02_資産管理.md`）
- [ ] AIコンサル事業戦略（`02_Business/01_事業戦略.md`）

### Obsidianプラグイン追加（推奨）

- [ ] **Periodic Notes** 導入
  - 週次・月次レビューの自動テンプレート生成
  - インストール：コミュニティプラグイン → 検索「Periodic Notes」

- [ ] **Tasks** 導入
  - Vault内のタスク一元管理
  - インストール：コミュニティプラグイン → 検索「Tasks」

- [ ] **Calendar** 導入
  - 日次ノートのカレンダービュー
  - インストール：コミュニティプラグイン → 検索「Calendar」

---

## Claude Code 活用コマンド（メモ）

```bash
# キャリア市場キャッチアップ
/career-catchup

# 企業調査
/career:company-research

# 面接Q&A生成
/career:qa-gen

# 書類カスタマイズ
/career:doc-custom
```
