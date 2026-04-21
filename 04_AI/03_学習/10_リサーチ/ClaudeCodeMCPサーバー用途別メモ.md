---
date: 2026-04-12
type: playbook
domain: ai
status: active
source: human
tags: [MCP, ClaudeCode, ツール, チャエン, カタログ]
---

# Claude Code MCP サーバー用途別メモ

**MCP** = Claude などを外部ツールに接続するプロトコル。レジストリ上のサーバーは多いが**玉石混交**なので、用途別に少数から入れるのが現実的。

**出典:** チャエン（X）6 カテゴリ整理 ／ mana（MakeAI CEO `@MakeAI_CEO`）「厳選 48」2026-04-11 頃の投稿要約。**URL・無料枠は変更されうる**ので導入前に各リポジトリ・公式を確認。

---

## A. チャエン整理（6 カテゴリ・超圧縮）

| カテゴリ | 例 |
| --- | --- |
| 開発支援 | GitHub, Figma, Playwright, Context7 |
| デザイン | Canva, Excalidraw, Mermaid Chart |
| ドキュメント | Notion, Google Drive/Sheets（**gog**） |
| コミュニケーション | Gmail, Calendar（**gog**）, Slack, Discord |
| 会計・営業 | freee（カスタム）, Salesforce（sf CLI）, Ahrefs |
| ブラウザ | Chrome DevTools（カスタム）, Claude in Chrome, Firecrawl |

運用: 変更系はドライラン・ToS 遵守。詳細は [[10_リサーチ/ClaudeCodeチャエン_スキルMCP運用]]・[[ClaudeCode_初期設定手順まとめ]] Step 7。

---

## B. MakeAI 厳選 48（用途別・一覧）

リポジトリは `github.com/<path>` で検索。**課金表記は投稿当時のメモ。**

### 検索・リサーチ（01–05）

| # | サーバー | メモ |
|---|----------|------|
| 01 | Tavily | AI 向け Web 検索（整理済み結果） |
| 02 | Exa | セマンティック検索 |
| 03 | Brave Search | 独立インデックス・ニュース等 |
| 04 | Perplexity | ソース統合・要約寄り |
| 05 | Context7 | ライブラリ最新ドキュメント |

### Web スクレイピング（06–09）

| # | サーバー | メモ |
|---|----------|------|
| 06 | Firecrawl | URL→Markdown、クロール定番 |
| 07 | Apify | 既製スクレイパー多数 |
| 08 | Bright Data | 厳しいアンチボット向け（有料中心） |
| 09 | Crawl4AI | OSS、Markdown 品質重視 |

### ブラウザ自動化（10–11）

| # | サーバー | メモ |
|---|----------|------|
| 10 | Playwright | 実ブラウザ操作・E2E |
| 11 | Browserbase | クラウドホストブラウザ |

### 開発ツール（12–17）

| # | サーバー | メモ |
|---|----------|------|
| 12 | GitHub | PR / Issue / コード |
| 13 | Linear | Issue・スプリント |
| 14 | Sentry | 本番エラー・スタック |
| 15 | Vercel | デプロイ・ビルドログ |
| 16 | Jira / Atlassian | チケット・JQL |
| 17 | Serena | LSP ベースのコードベース理解 |

### データベース（18–22）

| # | サーバー | メモ |
|---|----------|------|
| 18 | Supabase | Postgres・Auth・ストレージ |
| 19 | PostgreSQL | NL→SQL・スキーマ調査（読み取り既定） |
| 20 | MongoDB | Atlas 等・ツール多め |
| 21 | Neo4j | グラフ・関係分析 |
| 22 | Neon | サーバーレス Postgres・ブランチ |

### ベクトル・メモリ（23–26）

| # | サーバー | メモ |
|---|----------|------|
| 23 | Pinecone | クラウドベクトル |
| 24 | Qdrant | OSS・セルフホスト可 |
| 25 | Chroma | 軽量・プロトタイプ向け |
| 26 | Memory MCP | セッション横断メモリ |

### コード実行・ファイル（27–29）

| # | サーバー | メモ |
|---|----------|------|
| 27 | E2B | クラウドサンドボックスで実行 |
| 28 | Filesystem | ディレクトリ単位の読み書き制御 |
| 29 | YouTube | メタ・字幕・フレーム抽出 |

### ワークフロー（30）

n8n（セルフホスト可、MCP トリガ連携）。

### 生産性・コラボ（31–35）

Notion, Slack, Todoist, Zapier, Taskade。

### ビジネス・ファイナンス（36–38）

Stripe, HubSpot, Ahrefs。

### SNS・コンテンツ（39–40）

Publora（マルチ投稿）, Bluesky。

### デザイン・メディア（41–43）

Figma, Bannerbear, Draw.io。

### インフラ・監視（44–46）

Cloudflare, Docker, Grafana。

### AI 推論・メタ（47–48）

Sequential Thinking, Claude Code MCP（CC を MCP として公開）。

---

## C. 追加コマンド（Claude Code）

```bash
claude mcp add <name> -- npx -y @scope/package
claude mcp add <name> -e API_KEY=... -- npx -y @scope/package
claude mcp add --scope user <name> -- npx -y @scope/package
claude mcp add --transport http <name> https://example.com/mcp
claude mcp list
claude mcp remove <name>
```

Claude Desktop は `mcpServers` を `claude_desktop_config.json` に記述（公式手順に従う）。

---

## D. 最初の 3〜5 個（投稿の例）

| 役割 | 例の組み合わせ |
| --- | --- |
| 開発 | GitHub + Sentry + Context7 + Playwright |
| リサーチ | Tavily + Firecrawl + Exa |
| PM | Linear + Slack + Notion |
| 事業 | Stripe + HubSpot + Zapier |
| データ | Supabase + Firecrawl + Apify |
| SEO | Ahrefs + Exa + Firecrawl |

**注意:** 接続数が増えると**ツール説明だけでコンテキストを消費**する。Tool Search で遅延読み込みは緩和されるが、**スリム運用**が無難。

---

## 関連

- [[10_リサーチ/ClaudeCodeチャエン_スキルMCP運用]]
- [[../01_ツール運用/00_索引]]
- `.claude/skills/00_shared-governance.md`（外向き・スクレイプ・秘密）
