---
date: 2026-04-07
type: playbook
domain: ai
status: active
source: claude-code
reviewed: true
tags: [Vault運用, ClaudeCode, Obsidian, NotebookLM, 運用ガイド]
---

# Vault 運用マスターガイド

**このドキュメントを読めば、Claude Code・Obsidian・NotebookLMを人生の中心に据えて徹底活用できる。**

---

## 0. このシステムの思想

### なぜこのVaultを作ったか

> 「知識を持っているだけでは意味がない。再利用できる形に整理され、行動に繋がって初めて資産になる。」

このVaultは「第二の脳」であると同時に「自動化エンジンの燃料庫」。
- 人間がやること：判断・承認・経験を入力する
- AIがやること：構造化・検索・生成・提案をする

### 人生のどこにAIを置くか

```
人生の出来事・思考
      ↓ 記録（Obsidian）
      ↓ 分析（NotebookLM）
      ↓ 実行（Claude Code）
      ↓ 蓄積（Vault）
      ↓ 次の行動へ
```

このループを回すことで、経験が資産に変わる。

---

## 1. ツール役割・使い分け

→ **`01_AI活用整理.md`** を正本とする（ツール定義・判断フローはそちらで管理）

**このガイドでの最重要ルール：役割を混ぜない。**
- NotebookLMで編集しない（分析・壁打ちのみ）
- Claude Codeの生成物は `reviewed: false` のまま送信・提出しない
- 00_Inbox に入れたら翌日中に処理する

---

## 2. 日次・週次・月次ルーティン

### 毎日（5〜10分）

```
朝：
□ 00_Inbox を確認 → 適切なフォルダへ振り分け or 削除
□ 今日のタスクを確認（05_Life/20_events/ や 03_Career/40_転職活動/）

夜：
□ その日の重要な出来事・決定をObsidianに記録
□ 面接・商談があった日は即日記録（記憶が鮮明なうちに）
```

### 毎週（30分・週末推奨）

```
□ 80_Journal/ に週次振り返りを記録
   → Claude Codeに「今週のログをまとめて週次振り返りを作って」と頼む
□ 20_Input/02_Clippings/ と 20_Input/01_Kindle/ を処理
   → Claude Codeに「Clippingsを処理してドメインへ転記して」と頼む
□ 80_メモ（01_Work）のメモを昇格判断
   → 再利用できそうなものを 10_スキル/ か 20_プレイブック/ へ
□ 各フォルダのdraftファイルをレビュー → activeへ昇格 or 削除
```

### 毎月（60分・月初推奨）

```
□ NotebookLMで月次パターン分析
   → 80_Journal の週次振り返りを読み込み → 繰り返すパターンを抽出
□ 04_AI/80_実験ログ/ の一時メモを整理（正式フォルダへ昇格 or 削除）
□ 各ドメインのstatus確認（activeのままになっているが実は終わったものを archived に）
□ 05_Life/30_finance/ の家計・サブスクを見直し
□ 03_Career の転職活動状況を棚卸し
```

---

## 3. ファイルライフサイクル

全ファイルは以下の3状態を持つ。

```
draft → active → archived
```

| 状態 | 意味 | やること |
|---|---|---|
| `draft` | 草稿・未完成 | Claude Codeが生成した直後・人間が書きかけ |
| `active` | 現役・使用中 | 定期的に参照・更新する |
| `archived` | 完了・保存のみ | 更新しないが参照は残す → 99_archive/ へ移動 |

### archiveにするタイミング

| イベント | 対象ファイル | 操作 |
|---|---|---|
| 転職活動終了 | 03_Career/40_転職活動/ 配下 | status: archived → 99_archive/ へ |
| ライフイベント完了 | 05_Life/20_events/ のファイル | status: archived → 05_Life/99_archive/ へ |
| 設計書が古くなった | 04_AI 配下の設計ファイル | status: archived → 99_archive/ へ |
| 副業終了 | 03_Business/RINGBELL/ 配下 | status: archived → 99_archive/ へ |

**Claude Codeへの頼み方：**
```
「03_Career/40_転職活動/ 配下のファイルを全てarchived にして 99_archive/ へ移動して」
```

---

## 4. フロントマター運用ガイド

### 必須フィールド

```yaml
---
date: YYYY-MM-DD       # 作成日（更新日ではない）
type: [種別]           # 下記参照
domain: [ドメイン]     # 下記参照
status: active         # active / draft / archived
source: human          # human / claude-code / auto-sync
tags: []
---
```

### type 一覧

| type | 使う場面 |
|---|---|
| `index` | フォルダの目次・インデックスファイル |
| `resume` | 履歴書・職務経歴書 |
| `work-history` | 実績・経歴の詳細 |
| `pipeline` | 転職・案件の進捗管理 |
| `log` | 面接・トレーニング・日々の記録 |
| `playbook` | 業務フロー・手順書・再現可能な手順 |
| `design` | 自動化・システム設計 |
| `reference` | 参考資料・外部情報の整理 |
| `strategy` | 中長期方針・戦略ドキュメント |
| `template` | 繰り返し使う雛形 |
| `decision-log` | 意思決定の根拠・経緯 |
| `weekly-review` | 週次振り返り |
| `monthly-review` | 月次分析 |

### domain 一覧

| domain | 対応フォルダ |
|---|---|
| `career` | 03_Career/ |
| `work` | 01_Work/ |
| `business` | 03_Business/ |
| `asset` | 07_Asset/ |
| `athlete` | 09_Athlete/ |
| `beauty` | 11_Beauty/ |
| `life` | 05_Life/ |
| `relationship` | 08_Relationship/ |
| `journal` | 80_Journal/ |
| `ai` | 04_AI/ |
| `culture` | 10_Culture/ |

### AI生成ファイルの扱い

Claude Codeが生成したファイルには必ず付ける：

```yaml
source: claude-code
generated_at: YYYY-MM-DD
reviewed: false    # 人間がレビュー・編集したらtrue に変更
```

レビュー後：`source: human`・`reviewed: true` に更新。

---

## 5. 新ファイル作成テンプレート

### 週次振り返り

```markdown
---
date: YYYY-MM-DD
type: weekly-review
domain: journal
status: active
source: human
tags: [振り返り]
---

# 週次振り返り YYYY-WXX

## 良かったこと
- 

## 改善したいこと
- 

## 来週のアクション
- 

## 気づき・洞察
- 
```

### 意思決定ログ

```markdown
---
date: YYYY-MM-DD
type: decision-log
domain: [career/life/business]
status: active
source: human
tags: [意思決定]
---

# [決定事項のタイトル]

## 状況
何が起きていたか

## 選択肢
1. 
2. 

## 判断の根拠
なぜその選択をしたか

## 決定
何を選んだか

## 期待する結果
- 

## 振り返り（後日記入）
実際はどうだったか
```

### 面接ログ

```markdown
---
date: YYYY-MM-DD
type: log
domain: career
status: active
source: human
tags: [面接, 企業名]
---

# 面接ログ｜[企業名]｜[何次面接]

## 基本情報
- 日時：
- 面接官：（役職のみ）
- 形式：

## 聞かれたこと・答えたこと
| 質問 | 回答 | 反省 |
|---|---|---|

## 自分から聞いたこと
- 

## 感触・所感
- 

## 次のアクション
- 
```

---

## 6. Claude Code 活用パターン集

### キャリア・転職

```
「03_Career/10_プロフィール/ の実績データをもとに、[企業名]向けの志望動機を書いて」
「面接Q&Aログを整理して、よく聞かれる質問トップ10をまとめて」
「[企業名]の求人票と自分のスキルを比較して、強調すべき点と補強すべき点を整理して」
```

### 週次処理

```
「20_Input/02_Clippings/ の未処理ファイルを確認して、各ドメインへ洞察を転記して _processed_log.md を更新して」
「20_Input/01_Kindle/ の[書籍名]のハイライトから、実践できる学びを3つ抽出して 10_Culture/ に読書ログを作って」
「今週の80_Journal/ の記録をもとに週次振り返りを作って」
```

### ライフ管理

```
「05_Life/20_events/ のファイルを確認して、今月中にやることをリストアップして」
「05_Life/30_finance/ のサブスク一覧を見て、削減できそうなものを提案して」
```

### RINGBELL業務

```
「03_Business/RINGBELL/ の業務フローをもとに、[状況]の返信文案を3パターン作って」
「今月のKPIを記録して月次レポートを作って」
```

### Vault整理

```
「status: draft のファイルを全部リストアップして」
「99_archive/ に移動すべきファイルを提案して」
「フロントマターが付いていないファイルを探して一覧で出して」
```

---

## 7. Clippings・Kindle 処理フロー

### 処理の流れ

```
1. Claude Codeを起動
2. 「20_Input/02_Clippings/ を処理して」と依頼
3. Claude Codeが各ファイルを読んで
   → ドメイン判断（career/work/business/ai/athlete…）
   → 洞察・アクションを抽出
   → 該当ドメインフォルダへ転記
   → _processed_log.md に記録
4. 転記内容を人間がレビュー
5. 問題なければ完了
```

### 保存先の判断基準

| 記事・本の内容 | 転記先 |
|---|---|
| SaaS・営業・CS関連 | `01_Work/10_スキル/` |
| 転職・キャリア戦略 | `03_Career/30_キャリア戦略/` |
| AI・自動化・プロンプト | `04_AI/03_手法/` |
| 競技・トレーニング・栄養 | `09_Athlete/` 該当フォルダ |
| 美容・アンチエイジング | `11_Beauty/` |
| ライフプラン・お金 | `05_Life/30_finance/` |
| 人間関係・コミュニケーション | `08_Relationship/50_patterns/` |
| 読書・映画・文化 | `10_Culture/` |

---

## 8. NotebookLM 連携フロー

→ 詳細設計・ノートブック構成は **`03_NotebookLM運用.md`** を正本とする
→ ツール間の使い分けは **`01_AI活用整理.md` §4.5・§5.6** を参照

### このガイドでの要点のみ

| やること | 使うツール | 結果の保存先 |
|---|---|---|
| 月次パターン分析 | NotebookLM（80_Journal ノートブック） | `80_Journal/` に月次分析として保存 |
| トレーニング分析 | NotebookLM（09_Athlete ノートブック） | `09_Athlete/10_トライアスロン/` に保存 |
| ソース更新 | Obsidian側を編集 → 自動反映 | `98_NotebookLM_Sync/` 配下（直接編集しない） |

---

## 9. ドメイン別 活用重点ポイント

### 03_Career（転職中・最優先）
- 面接後は即日 `20_interviews.md` に記録
- 志望動機は企業ごとに `companies/<企業名>/` に保存
- 実績数値の正本は `10_プロフィール/20_work_history.md`（ここを正として書類を派生させる）

### 01_Work（入社後に本格稼働）
- `80_メモ/` に貯めたメモを週次で `10_スキル/` か `20_プレイブック/` へ昇格
- 「この会社でしか通じない情報」は書かず「次でも使えるナレッジ」を残す

### 03_Business/RINGBELL
- 返信文はClaude Codeで生成→必ず人間がトーン確認→送信
- 月次KPIは `AI自動化/` の設計に従って記録

### 09_Athlete
- ログは `98_NotebookLM_Sync/` に、分析結果・実行計画は `09_Athlete/` に
- 大会前はNotebookLMでテーパリング計画を生成

### 80_Journal
- 週次振り返りはClaude Codeに生成させて人間が加筆する運用でOK
- 月次はNotebookLMで週次ログを分析→パターン抽出→Journal に保存

---

## 10. よくある間違い・アンチパターン

| やりがちなこと | 正しい運用 |
|---|---|
| とりあえず保存して整理しない | 保存時に必ずフロントマターとドメインを決める |
| NotebookLMで直接編集する | 分析のみ。編集はObsidian側で行う |
| 生ログをそのまま残す | 洞察・アクションに変換してから保存 |
| CLAUDE.mdを更新せずフォルダを変える | フォルダ変更時は必ず対応するCLAUDE.mdも更新 |
| AI生成物をそのまま使う | `reviewed: false` のまま送信・提出しない |
| 全部00_Inboxに入れる | 入れたら必ず翌日中に処理する |

---

---

## 残課題（実装待ち）

### D. Clippings・Kindle 処理スクリプト
- **内容：** `20_Input/02_Clippings/` と `20_Input/01_Kindle/` の未処理ファイルを読んで、ドメイン判断・洞察抽出・転記・`_processed_log.md` 更新までを一連で行うスクリプトまたは定型プロンプト
- **効果：** 毎週「処理して」と一言頼むだけで完結する
- **推定工数：** 1〜2時間
- **優先度：** ★★★

### ④. Hook定義（自動トリガー）
- **内容：** `.claude/hooks/` にPost-Toolフックを定義し、「`20_Input/01_Kindle/` に新ファイルが追加されたら自動処理を起動」等のトリガーを設定する
- **効果：** 手動実行すら不要になる。真の自動化
- **推定工数：** 2〜3時間
- **優先度：** ★★（Dが完成してから）

---

**最終更新：2026-04-07**
