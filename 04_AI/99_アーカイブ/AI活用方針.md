> [!warning] Deprecated
> このファイルは旧版アーカイブ（更新停止）。
> 索引・正本ルールは `04_AI/README.md`。`01_ツール運用` の正本は以下：
> - `04_AI/01_ツール運用/01_ツール役割と運用.md`
> - `04_AI/01_ツール運用/02_フェーズとガバナンス.md`
> - `04_AI/01_ツール運用/03_NotebookLM.md`
> 実績・対外テンプレ（Deprecated）は `04_AI/99_アーカイブ/AI戦略_02_実績と対外説明.md`。
> 参照用途のみ。新規更新は README / 正本側で実施。

# AI活用方針（参照ハブ）

このファイルはハブ用途に変更。
最新の正本は以下を参照。

- `04_AI/README.md`（索引・正本ルール）
- `04_AI/01_ツール運用/01_ツール役割と運用.md`
- `04_AI/01_ツール運用/02_フェーズとガバナンス.md`
- `04_AI/01_ツール運用/03_NotebookLM.md`
- （参考・Deprecated）`04_AI/99_アーカイブ/AI戦略_02_実績と対外説明.md`

整合性維持のため、方針・ガバナンス・運用の更新は README と上記 `01_ツール運用` 内の正本で実施する。

---

# 【AI活用環境レポート（旧版アーカイブ）】

---

# ■ 0. 結論（本質）

```plaintext id="core_final"
AI活用とは
「ツールを使うこと」ではなく
「AIを前提とした仕事の構造（AI-OS）を設計すること」
```

---

# ■ 1. 成果（ビジネスアウトカム）

---

## ■ 定量成果

```plaintext id="outcome_final"
・業務時間：50〜80%削減
・アウトプット速度：2〜3倍
・思考整理速度：2倍
・自動化業務：10以上
```

---

## ■ ビジネスインパクト

```plaintext id="biz_impact"
・提案資料作成：3時間 → 30分
・会議意思決定：翌日 → 当日中
・情報発信：週0→週1〜2本安定化
・ナレッジ活用：属人化 → 再利用可能
```

---

👉 定義：
**効率化ではなく「意思決定と価値創出の加速」**

---

# ■ 2. 設計思想（Why）

---

## ■ なぜこの構造か

```plaintext id="why_design"
・人間は「判断」に集中するため
・AIは「処理」を担うため
・情報を「資産化」するため
・業務を「再現可能」にするため
```

---

## ■ 基本原則

```plaintext id="principles"
① 役割を分離する（混ぜない）
② 最適な場所で処理する
③ 最後に価値として統合する
```

---

# ■ 3. コンテキスト戦略（最重要）

```plaintext id="context_final"
短期：Cursor（作業・アウトプット）
中期：NotebookLM（理解・RAG）
長期：Obsidian（知識資産）
```

---

👉 意味：

* Cursor → 今やること
* NotebookLM → 正しく理解する
* Obsidian → 永続的に残す

---

👉 効果：

* 思考の質向上
* 再現性確保
* 知識の資産化

---

# ■ 4. ツール設計（役割固定）

---

```plaintext id="tools_final"
■ Cursor（中核UI）
・全操作の起点
・アウトプット最終責任

■ NotebookLM
・複雑情報の理解
・誤解防止

■ Obsidian
・知識資産化
・再利用

■ Claude Code
・業務分解
・ワークフロー設計
・自動化（エージェント）

■ Google Workspace Studio
・Google Workspace中心の業務自動化（共有/権限/監査）
・ログ/承認を前提にしたチーム運用

■ Opal
・業務フローを運用基盤として回す（権限/承認/ログ）
・チームで「誰が回しても同品質」を担保する自動化

■ Grok
・リアルタイム情報

■ Gemini / Claude
・AI検索 / 思考補助（Cursor経由）

■ Typeless
・音声思考入力

■ Whisk
・画像ミックス/合成（高速・大量生成）
・参照画像ベース編集（モデル/背景/スタイル）
・アスペクト比指定/一括生成（無料・透かし無し）

■ Veo（Flow経由）
・動画生成〜簡易編集まで一気通貫（制作の中核）
・画像→動画 / テキスト→動画の量産
・シーン結合（シーンビルダー）でカット編集を完結
・Fastで試作 → Qualityで本番（コスト最適化）

■ nanobanana Pro
・精密調整/一貫性重視の高品質画像生成
・細部の微修正/丁寧な仕上げ
・Whiskで試作 → 本番仕上げの最終工程
```

---

## 4.1 役割分担

```plaintext id="tools_roles"
入力（音声・思考出し） → Typeless
リアルタイム情報収集 → Grok
AI検索/壁打ち（作業中） → Cursor（Gemini / Claude）
複雑情報の理解/誤解防止（RAG） → NotebookLM
構造化/統合/執筆/最終アウトプット → Cursor
文章生成（提案書/記事/メール/Slack） → Cursor
要約/翻訳/リライト → Cursor
業務分解/テンプレ化/自動化（エージェント） → Claude Code（コア）
自動化のチーム運用（権限/承認/ログ/監査） → Google Workspace Studio / Opal
知識の蓄積/再利用（PKM） → Obsidian
ナレッジ更新/RAGソース整備 → Obsidian + NotebookLM

画像生成（精密・一貫性・本番） → nanobanana Pro
画像生成（試作・ミックス・大量） → Whisk
動画生成（画像→動画/テキスト→動画） → Veo（Flow経由）

会議の書き起こし（オンライン） → 標準書き起こし / Notta
会議の録音（オンライン/オフライン） → Pixel録音 / Hidock
会議要約/議事録化 → Cursor
会議からのタスク化 → Claude Code

ファクトチェック/出典確認 → Cursor（Gemini） + NotebookLM + Grok
```

---

👉 ルール：

```plaintext id="rule_final"
1ツール＝1役割（絶対に混ぜない）
```

---

## 4.2 自動化の運用パターン（個人 → チーム）

```plaintext id="automation_patterns"
【パターンA：個人最適（最速）】
目的：自分の生産性最大化 / 試作〜改善を高速で回す
中核：Claude Code + Cursor
特徴：自由度が高い／変更が速い／運用コスト最小

【パターンB：チーム運用（標準化・監査）】
前提：
・チーム運用にしたい（誰が回しても同品質、ログ、権限、承認）
・自動化がGoogle Workspace中心で、共有・権限・監査が重要
・「作って終わり」ではなく運用基盤として安定稼働させたい
中核：Google Workspace Studio（必要に応じて）+ Claude Code（設計/実装支援）
特徴：権限/承認/ログを前提に、業務フローとして標準化して回せる

【パターンC：ハイブリッド（おすすめ）】
設計/改善：Claude Codeで業務分解・プロンプト/手順を固める
運用/展開：Workspace側に載せて権限・承認・ログを担保する
```

---

# ■ 5. 基本フロー（統一オペレーション）

```plaintext id="flow_final"
① 情報収集（Grok / AI検索）
② 理解（NotebookLM）
③ 構造化（Cursor）
④ 実行 / 自動化（Claude Code）
⑤ 蓄積（Obsidian）
```

---

👉 目的：
**迷いゼロ・高速処理・再現性確保**

---

# ■ 6. 情報発信フロー（最適化）

---

```plaintext id="content_final"
① 思考出し
・Typeless（音声）

② 情報収集
・Cursor（Gemini / Claude）
・Grok（リアルタイム）
・NotebookLM（既存知識）
・Obsidian（資産）

③ 統合・構造化
・Cursor（最重要）

④ 執筆
・Cursorで完成
```

---

👉 本質：

```plaintext id="content_core"
思考 → 情報 → 構造 → 発信
```

---

# ■ 7. 会議運用（資産化）

---

## ■ 入力

```plaintext id="meeting_input_final"
・オンライン（イヤホンあり）
　→ 標準書き起こし / Notta

・オンライン（イヤホンなし）
　→ Pixel録音 / Hidock

・オフライン
　→ Hidock
```

---

## ■ 処理

```plaintext id="meeting_flow_final"
① 書き起こし
② NotebookLMで理解
③ Obsidian保存
④ Cursorで議事録
⑤ Claude Codeでタスク化
```

---

👉 定義：
**会議＝一過性ではなく資産**

---

# ■ 8. Claude Code（業務OS）

---

```plaintext id="agent_final"
・業務分解
・テンプレ化
・自動化
・再現性構築
```

---

👉 本質：

```plaintext id="agent_core"
人がやっていた仕事を
「構造」として再現する
```

---

# ■ 9. スケール戦略（具体）

---

```plaintext id="scale_final"
① 個人最適化
② 業務テンプレ化
③ ドキュメント化
④ 他者展開
⑤ 組織運用
```

---

👉 拡張：

```plaintext id="scale_expand"
1人 → 10人 → 100人
```

---

# ■ 10. 差別化（競争優位性）

---

```plaintext id="advantage_final"
① 音声入力 → 思考速度最大化
② RAG → 理解の精度向上
③ PKM → 知識資産化
④ エージェント → 再現性
⑤ UI統一 → 実行速度
```

---

👉 定義：

```plaintext id="advantage_core"
ツールではなく
「構造」で勝っている
```

---

# ■ 11. KPI（経営指標）

---

```plaintext id="kpi_final"
・削減時間
・アウトプット数
・自動化数
・意思決定速度
・売上 / CVR改善
```

---

# ■ 12. 契約ツール（最適コスト）

---

```plaintext id="cost_final"
■ Cursor Pro：$20/月
■ Gemini Advanced：約¥2,900/月
■ Claude Pro：$20/月
■ Grok（X）：¥1,000〜¥2,000/月
■ NotebookLM：無料
■ Obsidian：無料
■ Typeless：無料〜
```

---

## ■ 合計

```plaintext id="cost_sum"
約¥7,000〜¥12,000/月
```

---

👉 評価：

```plaintext id="cost_eval"
極めて高ROI（時間・成果換算で圧倒的プラス）
```

---

# ■ 13. AI人材としての価値

---

```plaintext id="talent_final"
・業務を構造化できる
・AIで再現可能な仕組みを作れる
・知識を資産化できる
・高速でアウトプットできる
・組織展開可能
```

---

👉 定義：

```plaintext id="talent_core"
AIを使う人ではなく
AI前提で仕事を設計できる人
```

---

# ■ 最終結論

```plaintext id="final_conclusion"
この環境は
・無駄がない
・再現性がある
・拡張可能

＝即戦力レベル（上位1%）
```

---

# ■ 14. 実装ユースケース

---

```plaintext id="usecases_final"
・面談準備自動化
・面談レポート生成
・Slack報告生成
・メール返信生成
・議事録要約
・リサーチ整理
・顧客対応生成
```

---

👉 特徴：

```plaintext id="usecases_feature"
業務フローとして再現可能
```

---

# ■ 15. 企業への提供価値

---

## ■ 生産性向上

```plaintext id="value_productivity"
・業務時間50〜80%削減
・自動化による効率化
```

---

## ■ コスト削減

```plaintext id="value_cost"
・属人化排除
・教育コスト削減
```

---

## ■ 売上貢献

```plaintext id="value_revenue"
・アウトプット高速化
・顧客対応品質向上
```

---

## ■ 組織展開

```plaintext id="value_scale"
・再現可能
・チーム展開可能
```

---

👉 定義：

```plaintext id="value_definition"
組織導入可能なAI運用モデル
```

---

# ■ 16. 導入後の変化（To-Be）

---

```plaintext id="tobe_final"
■ 業務
手作業 → 自動化

■ 組織
属人 → 標準化

■ 意思決定
遅い → 即時
```

---

👉 結果：

```plaintext id="tobe_result"
人に依存しない組織へ
```

---

# ■ 17. 提供可能領域（コンサル視点）

---

```plaintext id="offerings_final"
・業務ヒアリング
・課題特定
・AI適用設計
・導入支援
・運用改善
```

---

👉 役割：

```plaintext id="offerings_role"
AIで業務を設計する人材
```

---

# ■ 18. 導入スピード

---

```plaintext id="adoption_speed"
1週間：個人導入
2〜4週間：業務最適化
1〜2ヶ月：チーム展開
```

---

👉 特徴：

```plaintext id="adoption_feature"
スモールスタート可能
```

---
