# Vault グローバルコンテキスト

## このVaultについて
個人の知識管理・業務自動化・キャリア管理を一元化したObsidian Vault。
Google Drive経由で同期し、Cursor/Claude Codeで編集、NotebookLMで分析する。

## オーナープロフィール
- IT業界・SaaS領域（Sales / Customer Success 方向）
- 転職活動中（2026-04時点）
- 副業：RINGBELL（婚活CS業務）
- 個人事業：AIコンサル・AI活用支援
- 目標：AIで事業成果を再現可能に作れる人材として市場価値を上げる

## ツール役割（1ツール1責任）
| ツール | 役割 |
|---|---|
| Claude Code | 業務自動化・エージェント実行（このツール） |
| Cursor | 全操作の中核UI・最終成果物化 |
| NotebookLM | ソース限定の壁打ち・根拠検証 |
| Obsidian | 知識の永久保存（このVault） |
| Claudeプロジェクト | 戦略壁打ち・文脈蓄積 |

詳細：`04_AI/01_ツール運用/01_AI活用整理.md`

## Vaultフォルダ構成
```
# ── 業務・キャリア（内向き/外向き）──────────────────
00_Inbox        一時受信
01_Work         本業実務・スキル蓄積（内向き）
02_Business     個人事業戦略
  └ RINGBELL/   副業（婚活CS）実務
03_Career       キャリア戦略・転職管理（外向き）
04_AI           AI戦略・自動化（正本群）

# ── ライフ系（05〜11 で人生全般を管理）────────────────
05_Life         共同生活インフラ（住宅・家計・契約・イベント）
  └ 11_health/ 20_events/ 30_finance/ 40_agreements/ 50_housing/ 60_insurance/ 70_decisions/ 80_documents/ 99_archive/
06_Child        子ども関連
07_Asset        所有物管理（服・靴・鞄・ガジェット等）
08_Relationship パートナー・家族・人間関係
  └ 10_partner/ 20_family/ 30_network/ 40_friends/ 50_patterns/
09_Athlete      競技・身体パフォーマンス
  └ 10_トライアスロン/ 20_登山/ 30_筋トレ/ 40_運動/ 50_健康/ 60_睡眠/ 70_食事/
10_Culture      文化系趣味・教養・学習
11_Beauty       美容・アンチエイジング
# ── 12〜19 は将来拡張用に予約（現在未使用）───────────

# ── インプット・ログ・システム ─────────────────────
20_Input        インプット系（自動同期）
  └ 01_Kindle/  読書ハイライト（自動同期）
  └ 02_Clippings/ Webクリッピング（自動入力）
80_Journal      思考ログ（Daily / Voice）
98_NotebookLM_Sync  NotebookLMソース（編集しない。対応表は00_index.md参照）
99_System       Vault設定
```

## 正本ファイル（迷ったら参照）
- ツール役割・情報フロー・課金：`04_AI/01_ツール運用/01_AI活用整理.md`
- Phase・現在地・KPI・ガバナンス：`04_AI/01_ツール運用/02_AIキャッチアップ.md`
- NotebookLM 11冊設計：`04_AI/01_ツール運用/03_NotebookLM運用.md`
- 各フォルダに入れるべきデータ一覧：`04_AI/01_ツール運用/05_データ蓄積ガイド.md`
- 宿題・ペンディングタスク：`04_AI/80_実験ログ/20260408_宿題リスト.md`

## 情報フロー原則
1. 収集 → 2. 理解 → 3. 構造化 → 4. 実行 → 5. 蓄積
- Obsidianには「生ログ」ではなく「資産化済みアウトプット」を保存する
- 再利用できる形にしてから保存する（「とりあえず保存」しない）

## 作業時のルール
- クライアント固有情報・個人情報はVaultに入れない（匿名化してから）
- 機微情報の投入可否は `04_AI/01_ツール運用/02_AIキャッチアップ.md` を正とする
- 顧客・会員向けの自動生成は人間承認前に送信しない
- `98_NotebookLM_Sync/` 配下は直接編集しない（Obsidian側を編集→自動反映）

---

## デイリーノート（日次ログ）

- **保存先:** `80_Journal/01_Daily/YYYY-MM-DD.md`（ファイル名の日付は **ハイフン付き** で統一）
- **役割:** その日の「今日やること」とメモ・気づきを残す（詳細な書き方・禁止事項は `80_Journal/CLAUDE.md`）
- **テンプレ正本:** `99_System/Templates/Daily.md`
- **「今日やること」の内訳（固定）:** `本業`（`1.–3.`）/ `RINGBELL`（`1.–3.`）/ `学習`（`1.–2.`）/ `運動 / トレーニング`（`1.–2.`）/ `その他`（`1.–2.`）の5見出し（`###`）。詳細は `99_System/Templates/Daily.md`
- **Cursor での作成:** エージェントに音声またはチャットで依頼する（例:「今日のデイリーテンプレートを作って」／短文の「おはよう」のみ、など）。**トリガー条件・繰り越し手順・ファイル生成の細目は、Cursor が毎回読むプロジェクトルール `.cursor/rules/daily-note-voice.mdc` に書いてある。** Vault 根の `CLAUDE.md`（本書）は要約；実装の取り違えを避けるときは **`.mdc` を正**とする。
- **Claude Code / Claude プロジェクト / 他ツール:** デイリーを新規作成・追記するときは、本節に加え **`80_Journal/CLAUDE.md`**・**`99_System/Templates/Daily.md`** を参照し、Cursor 併用時は **`.cursor/rules/daily-note-voice.mdc`** も読んで手順を揃える。

---

## ファイルフロントマター規約

全ファイルの先頭に以下のYAMLを付ける。AIエージェントによる自動処理・検索に必須。

```yaml
---
date: YYYY-MM-DD          # 作成日
type: [ファイル種別]       # weekly-review / decision-log / playbook / template / log 等
domain: [ドメイン名]       # career / work / business / athlete / life / journal / ai 等
status: active             # active / archived / draft
source: human              # human / claude-code / auto-sync
tags: []
---
```

- `source: auto-sync` — Clippings・Kindle等の自動入力ファイル
- `source: claude-code` — Claude Codeが生成したファイル（`reviewed: false` を併記）
- `source: human` — 人間が作成・編集したファイル

---

## AI生成物マーク規約

Claude Codeが生成したファイルには必ず以下を付ける：

```yaml
---
source: claude-code
generated_at: YYYY-MM-DD
reviewed: false    # 人間がレビュー・編集したらtrueに変更
---
```

レビュー済みになったら `source: human`・`reviewed: true` に更新すること。

---

## 命名規則

| 種別 | 規則 | 例 |
|---|---|---|
| イベント・ログ系 | `YYYYMMDD_名前.md` | `20260613_引越し.md` |
| インデックス・設計系 | `NN_名前.md` | `01_AI活用整理.md` |
| フォルダ | `NN_名前`（番号必須・日本語または英語で統一） | `10_トライアスロン/` |
| 処理ログ | `_processed_log.md`（アンダースコア始まり） | `_processed_log.md` |
