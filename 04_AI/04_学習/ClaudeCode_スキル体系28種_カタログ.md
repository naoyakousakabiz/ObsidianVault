---
date: 2026-04-09
type: playbook
domain: ai
status: active
source: human
tags: [ClaudeCode, Skills, カタログ, チャエン]
---

# Claude Code スキル体系（28種+）

> **出典・位置づけ:** チャエン資料のスキル分類を整理した**参照用カタログ**（コマンド名・用途の早見）。**実体のスキルファイルは配布元・`.claude/skills/` に別途必要。** 全文脈・運用・MCPは [[ClaudeCode_チャエン完全まとめ_スキルMCPコマンド運用_20260328]] を正とする。  
> **Cursor** の `/コマンド` や Agent Skills とは**別物**（[[../03_手法/ClaudeCode_スキル作成_ベストプラクティス]]）。

> **スキル（Skills）とは？** `.claude/skills/` に配置するカスタムプロンプトファイル。`/スキル名` で呼び出し、複雑な業務を一発で自動化できる。

### 成果物・形式・保存先（このノートの表の見方）

| 列 | 意味 |
|:---|:---|
| **成果物** | そのスキル実行後に「残るもの」（ファイル・下書き・投稿・DB行など） |
| **形式** | `.md` / `.xlsx` / Gmail下書き 等 |
| **保存先** | チャエン例（`clients/` …）が多い。**この Vault では** `80_Journal/`・キャンペーンフォルダ・`00_Inbox` 経由など**運用ルールに合わせて置換**すること |

---

## 2-1. 📄 文書生成スキル（8種）

> ⭐ 業務で最も使用頻度が高いカテゴリ。会議後の処理から提案書作成まで、文書作成はほぼ全自動。

### `/post-meeting` — 最強の会議後自動化

**処理フロー：** 文字起こし → クライアント自動判定 → カレンダー補完 → 議事録生成（MD + DOCX） → Gmail下書き作成 → Slack報告 + Notion更新 → ✅ 5つの成果物

| # | 成果物 | 形式 | 保存先 |
|---|--------|------|--------|
| 1 | 議事録（プレーンテキスト） | .md | clients/顧客名/minutes/ |
| 2 | 議事録（フォーマット済み） | .docx | clients/顧客名/minutes/ |
| 3 | 御礼メール下書き | Gmail下書き | Gmailの下書きフォルダ |
| 4 | Slack社内報告 | Slackメッセージ | #meeting-notes |
| 5 | Notion DB更新 | DBレコード | Notion Meetings DB |

**依存ツール：** gogcli（Gmail）, Google Calendar, Notion MCP, Slack MCP

---

### `/generate-proposal-excel` — 11シートAI提案書Excel

> 📊 ヒアリング内容から **11シート** のExcelを一発自動生成。コンサル顔負けの精度。

| Sheet | シート名 | 内容 |
|-------|----------|------|
| 1 | サマリー | タイトル, クライアント名, 事業概要, カテゴリ別課題と概算 |
| 2 | AI活用課題一覧 | チェックボックス, 優先度, 難易度, AI解決策, 期待効果, 工数, 概算 |
| 3 | お見積り（統合） | 総額, 総工数, 単価, カテゴリ別セクション |
| 4-8 | 見積り詳細 A〜E | カテゴリ別（現状→解決策→期待効果→工程別工数） |
| 9 | 実行ロードマップ | 24週間ガントチャート |
| 10 | プロジェクト体制 | 支援/クライアント体制図 |
| 11 | 次回会議アジェンダ | 会議情報, アジェンダ表, 目標, 準備依頼 |

**成果物・形式・保存先（代表）**

| 成果物 | 形式 | 保存先（例） |
|--------|------|----------------|
| AI提案書（11シート） | .xlsx | `clients/…/proposals/` または `output/`（プロジェクト命名に合わせる） |
| 生成ログ・メモ | .md（任意） | 同フォルダまたは `00_Inbox` 起票後に正本へ |

---

### その他の文書生成スキル

| # | コマンド | 用途 | 主な成果物 | 形式 | 保存先（例） |
|---|----------|------|------------|------|----------------|
| 3 | `/universal-meeting-minutes` | 汎用議事録・多派生物 | 議事録＋短報・メール案等 | .md（＋任意） | `clients/…/minutes/` ／ **Vault:** `80_Journal`・`01_Work/80_メモ` 等（ルールに従う） |
| 4 | `/auto-minutes` | Zoom等・録画／字幕起点 | 清書議事録 | .md | 録画と同階層・`minutes/` ／ **Vault:** 上同 |
| 5 | `/generate-eval-excel` | 人事評価ブック | HR評価ブック | .xlsx（15シート） | `hr/`・`clients/…` 等（社内ルール） |
| 6 | `/digirise-proposal` | 提案ダッシュボード＋表 | Webアプリ＋Excel | ディレクトリ＋.xlsx | `projects/…/proposal-app/` 等 |
| 7 | `/digirise-presentation` | スライド | 提案・報告スライド | .pptx | `decks/`・`clients/…/slides/` |
| 8 | `/talmood-invoice` | 請求・入出金記録 | 請求データ＋Sheets行 | freee＋Sheets | クラウド（freee／Drive） |

---

## 2-2. 🌐 Web・リサーチスキル（7種）— Firecrawlファミリー

> 💡 **エスカレーションフロー（使い分けの鉄則）** — 軽い検索から始めて、必要に応じてより深く掘る設計

**フロー：** search（URL不明）→ scrape（URL判明）→ map（サイト内探索）→ crawl（全体必要）→ agent（構造化）→ browser（JS操作）→ download（保存）

| # | コマンド | 用途 | 使うタイミング |
|---|----------|------|--------------|
| 9 | `/firecrawl-search` | Web検索＋全文取得 | まずURLが分からない時。Google検索のように使うが全文も取得可能 |
| 10 | `/firecrawl-scrape` | URL→Markdown変換 | 特定URLの中身を取りたいとき。JS描画ページも対応 |
| 11 | `/firecrawl-map` | サイト内URL一覧 | 「このサイトのどこに何がある？」を把握したいとき |
| 12 | `/firecrawl-crawl` | サイト一括抽出 | ドキュメントサイトを丸ごと取得したいとき |
| 13 | `/firecrawl-agent` | AI構造化抽出（JSON） | 複数ページからJSON構造化データを自動抽出したいとき |
| 14 | `/firecrawl-browser` | ブラウザ自動操作 | ログイン・フォーム入力・ページネーション処理が必要なとき |
| 15 | `/firecrawl-download` | サイトのローカル保存 | サイト全体をMarkdownでオフライン保存したいとき |

**成果物・形式・保存先（Firecrawl 共通の考え方）**

| コマンド | 成果物 | 形式 | 保存先（例） |
|----------|--------|------|----------------|
| `/firecrawl-search` | 検索結果＋取得本文 | Markdown／JSON | `./research/YYYYMMDD_topic/` |
| `/firecrawl-scrape` | 1ページ抽出 | Markdown | 同上または `20_Input/02_Clippings` 系（**Vault の蓄積ルール**優先） |
| `/firecrawl-map` | URL 一覧 | .md / .json | `./research/…/urls.md` |
| `/firecrawl-crawl` | 複数ページ本文 | Markdown（複数） | `./research/…/crawl/` |
| `/firecrawl-agent` | 構造化データ | JSON | `./research/…/extracted.json` |
| `/firecrawl-browser` | 操作ログ・スクショ想定の成果 | .md 等 | `./research/…/` |
| `/firecrawl-download` | サイトミラー | 複数 .md / アセット | `./archive/<site>/` |

※ 実パスは**都度ユーザー確認**。`98_NotebookLM_Sync/` 等 **編集禁止領域には書かない**。

---

## 2-3. 🔗 外部連携・自動化スキル（6種）

> 🔗 Claude Code の真価は外部サービスと繋がったときに発揮されます。これらのスキルが「右腕」を「右腕+両手+両足」に進化させる。

| # | コマンド | 何をするか | 連携先 | 実行 |
|---|----------|-----------|--------|------|
| 16 | `/gogcli` | Google Workspace一括操作。Gmail/Calendar/Drive/Sheets/Docs/Tasks/Chat | Google | 手動 |
| 17 | `/sf-daily-report` | Salesforce日次営業レポート。商談状況・パイプライン・活動量を自動集計 | Salesforce | 毎日自動 |
| 18 | `/sync-client-registry` | Notion顧客DB双方向同期。ローカルのCLAUDE.mdとNotion Clients DBを自動同期 | Notion | 手動 |
| 19 | `/pre-meeting-setup` | 会議前の自動準備。カレンダーから新規予定を検出し、フォルダ・CLAUDE.mdを自動作成 | Google Calendar | 毎朝自動 |
| 20 | `/morning-briefing` | 毎朝の自動ブリーフィング。ニュース・Gmail・カレンダー・Slackをチェック → テキスト＋音声で送信 | Gmail/Slack/Grok | 毎朝自動 |
| 21 | `/remotion-video` | ずんだもん動画生成。Remotion（React）でプログラマブルに解説動画を作成 | Remotion | 手動 |

**成果物・形式・保存先（例）**

| コマンド | 成果物 | 形式 | 保存先（例） |
|----------|--------|------|----------------|
| `/gogcli` | メール下書き・予定・シート更新 | クラウド上の各種 | Gmail／Calendar／Drive（認証済みアカウント） |
| `/sf-daily-report` | 日次レポート | .md / .pdf / SF上レポート | メール送信・SF・`reports/` |
| `/sync-client-registry` | 同期差分・更新後DB | Notionページ／ローカルmd | Notion DB + `clients/…/CLAUDE.md` 等 |
| `/pre-meeting-setup` | 会議用フォルダ・テンプレ | ディレクトリ＋.md | `clients/…/meetings/YYYY-MM-DD/` |
| `/morning-briefing` | ブリーフィング本文＋任意音声 | .md / .m4a | メール・Slack DM・`briefings/` |
| `/remotion-video` | 動画・中間ファイル | .mp4 + Remotionプロジェクト | `videos/out/`・`remotion/` |

### `/morning-briefing` の処理フロー

**毎朝7:00 自動起動** → Grok ニュース取得 → Gmail 未読チェック → Calendar 今日の予定 → Slack 未読チェック → ブリーフィング テキスト生成 → 音声ファイル生成 → ✅ 配信

---

## 2-4. 🔧 ユーティリティスキル（7種）

> 🔧 地味だけど毎日使う。これがないと不便でしょうがないスキル群。

| # | コマンド | 何をするか | 頻度 |
|---|----------|-----------|------|
| 22 | `/downloads-triage` | Downloadsフォルダを自動整理・分類（画像/PDF/Excel/動画 等） | 毎週月曜 自動 |
| 23 | `/claude-md-improver` | CLAUDE.mdを6基準・100点満点で品質監査 → A〜Fスコア → 自動改善 | 月1回 |
| 24 | `/generate-article-images` | Gemini API（Nano Banana 2）で章ごとの日本語図解アイキャッチ画像を自動生成 | 記事作成時 |
| 25 | `/edit-vertical-video` | 縦型動画の自動編集（字幕追加・無音カット・ポップBGM・E2Eテスト）。Shorts/Reels/TikTok向け | 動画作成時 |
| 26 | `/job-eyecatch` | 求人アイキャッチ画像を自動生成 | 採用時 |
| 27 | `/revise-claude-md` | セッションで学んだことからCLAUDE.mdを自動アップデート | セッション終了時 |
| 28 | `/simplify` | 変更コードの品質レビュー＆リファクタリング提案 | コード変更後 |

**成果物・形式・保存先（例）**

| コマンド | 成果物 | 形式 | 保存先（例） |
|----------|--------|------|----------------|
| `/downloads-triage` | 整理後のファイル配置・ログ | ファイル移動＋任意 .md ログ | `~/Downloads` 配下サブフォルダ（ルール合意後） |
| `/claude-md-improver` | 採点・改善提案 | チャット出力（任意で差分パッチ） | `CLAUDE.md` 更新は**ユーザー承認後** |
| `/generate-article-images` | 章アイキャッチ | .png / .webp | `assets/article/<slug>/` |
| `/edit-vertical-video` | 編集済み動画 | .mp4 | `videos/vertical/out/` |
| `/job-eyecatch` | 求人バナー | 画像 | `recruiting/assets/` |
| `/revise-claude-md` | `CLAUDE.md` 追記・リライト案 | .md 差分 | リポジトリ直下・ドメイン別 `CLAUDE.md` |
| `/simplify` | レビューコメント・パッチ提案 | チャット／diff | 対象ソースと同階層（PR想定） |

---

## 2-5. ⌨️ 入力補助スキル（3種）

> ⌨️ Claude Code の10,000字ペースト制限を回避する裏ワザ。長文の文字起こしや議事録を投入するときに必須。

| コマンド | 入力元 | 用途 |
|----------|--------|------|
| `/lp` | クリップボード | コピーした長文をペースト制限なしで入力 |
| `/le` | エディタ | エディタが開き、入力・保存すると処理開始 |
| `/lf` | ファイル指定 | 大容量ファイルの内容を読み込んで処理 |

**成果物・形式・保存先**

| コマンド | 成果物 | 形式 | 保存先 |
|----------|--------|------|--------|
| `/lp` | セッションへ取り込まれたテキスト | （プロンプト内テキスト） | 保存しない／続くスキルがファイル化 |
| `/le` | 同上（エディタ経由） | 一時 .md 等 | 作業ディレクトリ（ユーザー指定） |
| `/lf` | 指定ファイルの内容参照 | 既存ファイル | **パスを指示**（例: `tmp/transcript.md`） |

---

*合計：28種以上のスキルで業務を全自動化*
