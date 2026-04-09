# エージェント用スキル一覧

手順・境界・完了条件を短くまとめたファイル群です。Claude Code / Cursor では `@ファイル名` やスキル名を会話に入れると、内容に沿って動きやすくなります。

## スキル1ファイルの型（共通）

| 要素 | 役割 |
|------|------|
| YAML（id / version / domains / requires / related） | 検索や関連スキル、**ざっくりした前提**の把握 |
| **前提条件** | うまく回すために必要な環境・入力・権限を人向けに明示 |
| いつ使うか / **使わないほうがよい場合** | 取り違えを減らす |
| **依頼例** | コピペ1行で指示のブレを抑える |
| **成果物一覧（表）** | 複数アウトプットがあるスキルは、**成果物・形式・保存先（例）**を表で示す（`post-meeting` など） |
| **完了の目安** | 品質の下限・レビュー時のチェック |
| 共通ルールへのリンク | [00_shared-governance.md](./00_shared-governance.md) |

## 早見表

| ファイル | コマンド風 | 一言 | 典型シーン |
|----------|------------|------|------------|
| [auto-minutes.md](./auto-minutes.md) | `/auto-minutes` | Zoom 等の議事録ドラフト | 録画・字幕・メモから議事録のたたき台 |
| [universal-meeting-minutes.md](./universal-meeting-minutes.md) | `/universal-meeting-minutes` | 型バラの会議の議事録＋派生物 | 1on1・社内外・フォーマット不定 |
| [post-meeting.md](./post-meeting.md) | `/post-meeting` | 会議後フォロー一式 | 議事録＋メール/Slack/Notion まで |
| [pre-meeting-setup.md](./pre-meeting-setup.md) | `/pre-meeting-setup` | 会議前の下ごしらえ | フォルダ・チェックリスト・アジェンダ素案 |
| [morning-briefing.md](./morning-briefing.md) | `/morning-briefing` | 朝の情報を1本化 | 予定・メール・チャット要点のサマリ |
| [simplify.md](./simplify.md) | `/simplify` | コード簡素化レビュー | PR・可読性・小さなリファクタ案 |
| [downloads-triage.md](./downloads-triage.md) | `/downloads-triage` | Downloads 整理設計 | 分類ルール・移動手順（削除は本人） |
| [edit-vertical-video.md](./edit-vertical-video.md) | `/edit-vertical-video` | 縦動画の編集設計 | ffmpeg 前提・字幕・BGM・無音カット |
| [remotion-video.md](./remotion-video.md) | `/remotion-video` | Remotion で解説動画 | コードでレンダリング・テンプレ量産 |
| [generate-article-images.md](./generate-article-images.md) | `/generate-article-images` | 記事用アイキャッチ | 章ごと画像プロンプト・alt 案 |
| [job-eyecatch.md](./job-eyecatch.md) | `/job-eyecatch` | 求人ビジュアル案 | 採用バナー・サムネのプロンプト複数 |
| [digirise-presentation.md](./digirise-presentation.md) | `/digirise-presentation` | スライド生成 | .pptx・python-pptx・ブランド遵守 |
| [digirise-proposal.md](./digirise-proposal.md) | `/digirise-proposal` | 提案ダッシュボード | Vite+React+Tailwind・公開範囲の設計 |
| [generate-proposal-excel.md](./generate-proposal-excel.md) | `/generate-proposal-excel` | 11シート提案書 Excel | ヒアリングから xlsx 草案 |
| [generate-eval-excel.md](./generate-eval-excel.md) | `/generate-eval-excel` | 人事評価 Excel（15シート型） | 評価テンプレ設計・集計のたたき台 |
| [gogcli.md](./gogcli.md) | `/gogcli` | Google Workspace CLI | Gmail/Calendar/Drive/Sheets の操作設計 |
| [sync-client-registry.md](./sync-client-registry.md) | `/sync-client-registry` | Notion 顧客DB と同期 | マッピング・差分・競合ルール |
| [sf-daily-report.md](./sf-daily-report.md) | `/sf-daily-report` | Salesforce 日次 | パイプライン等の読取スナップショット |
| [talmood-invoice.md](./talmood-invoice.md) | `/talmood-invoice` | 請求フロー（freee想定） | 請求設計・Sheets 連携・APIは秘密扱わない |
| [firecrawl-search.md](./firecrawl-search.md) | `/firecrawl-search` | Web検索＋本文 | URL が未確定の調査の入口 |
| [firecrawl-scrape.md](./firecrawl-scrape.md) | `/firecrawl-scrape` | 1URL→Markdown | 決め打ち1ページの本文 |
| [firecrawl-map.md](./firecrawl-map.md) | `/firecrawl-map` | サイト内URL一覧 | crawl 前の枚数・範囲の見積もり |
| [firecrawl-crawl.md](./firecrawl-crawl.md) | `/firecrawl-crawl` | サイト一括取得 | 広域・コーパス化（範囲と上限必須） |
| [firecrawl-agent.md](./firecrawl-agent.md) | `/firecrawl-agent` | JSON構造化抽出 | スキーマに沿った抜き取り |
| [firecrawl-browser.md](./firecrawl-browser.md) | `/firecrawl-browser` | ブラウザ相当の取得 | JS・操作前提のページ |
| [firecrawl-download.md](./firecrawl-download.md) | `/firecrawl-download` | ローカル保存・退避 | オフライン副読本（権利に注意） |

## Firecrawl 系の選び方

軽い順に、**必要なものだけ**使うイメージです。

1. **search** — 何を読むか未確定  
2. **scrape** — URL が決まっている  
3. **map** — 同一サイトの全ページ感を掴む  
4. **crawl / agent / browser / download** — 広域・構造化・操作・丸ごと保存  

## 頼み方

- `@スキル名.md` か「`/コマンド風` で」と書く。  
- 機微はマスクする。詳しくは [00_shared-governance.md](./00_shared-governance.md)。
