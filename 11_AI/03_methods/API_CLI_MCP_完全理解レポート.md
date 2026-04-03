# API・CLI・MCP 完全理解レポート

---

## 1. 全体像：全部の根っこは「API」

CLIもZapierもMCPも、裏側では全てAPIを叩いている。
違いは「誰が・どうやってAPIを使うか」だけ。

```
API    → 仕組みそのもの（根っこ）
CLI    → APIをエンジニア向けに簡単にしたツール
Zapier → APIを非エンジニア向けに簡単にしたツール
MCP    → APIをAI向けに統一した規格
```

---

## 2. API（Application Programming Interface）

### 定義

外部から機能を呼び出す仕組み全体。
エンドポイント（URL）にリクエストを送って、レスポンスをもらう。

### リクエストの正確な構造

APIキーはリクエストの「認証ヘッダー」という部分に含まれる。
リクエスト全体とAPIキーは別物。

```
リクエスト全体：
  ├── 送信先URL（エンドポイント）
  │     例）https://salesforce.com/api/leads
  ├── 認証ヘッダー ← ここにAPIキーが入る
  │     例）Authorization: Bearer sk-abc123...
  ├── 送るデータ
  │     例）{氏名: "田中太郎", 会社: "ABC"}
  └── 何をしたいか（作成・取得・更新・削除）
```

### APIエンドポイントは機能ごとに異なる

```
リードを作成する → /sobjects/Lead
リードを検索する → /query
リードを更新する → /sobjects/Lead/{id}
リードを削除する → /sobjects/Lead/{id}
商談を作成する   → /sobjects/Opportunity
```

---

## 3. 認証方式：APIキー vs OAuth

### APIキー

ランダムな文字列の合言葉。リクエストの認証ヘッダーに毎回含めて送る。

**向いてるケース：** サーバー同士の自動処理（人間が関与しない）
例）毎晩0時に自動でSalesforceにデータを送るバッチ処理

**問題点：**

- 漏れたら即アウト（知ってる人は誰でも使える）
- 誰のキーか不明（監査ログが残らない）
- 有効期限がなく定期更新が必要

**最小権限の原則：**

```
悪い例：全権限        → 漏れたら全データが危険
良い例：必要な操作のみ → 漏れても被害が限定的
```

### OAuth（オーオース）

本人確認ベースの認証。「Googleでログイン」と同じ仕組み。

**向いてるケース：** 人間が関与する連携
例）営業担当者が自分のSalesforceアカウントでLubeに認証する

**メリット：**

- 個人単位で管理できる
- 監査ログが残る（誰が何をしたか追跡可能）
- 企業向け販売では必須要件になることが多い

### APIキー vs OAuth 比較表

| | APIキー | OAuth |
|---|---|---|
| 向いてるケース | サーバー同士の自動処理 | 人間が関与する連携 |
| 具体例 | 毎晩0時の自動バッチ | 「Googleでログイン」 |
| 管理 | 漏れたら即アウト・誰のキーか不明 | 個人単位・監査ログあり |
| 難易度 | シンプル | やや複雑 |

---

## 4. CLI（Command Line Interface）

### 定義

APIをエンジニア向けに簡単にしたコマンドツール。
ターミナルでコマンドを打つだけで操作できる。
裏側では同じAPIを叩いている。

### APIとCLIの比較（GitHub操作の例）

```
APIで直接やる場合：
  送信先URL   : https://api.github.com/repos
  認証ヘッダー: Authorization: Bearer ghp_abc123...
  データ      : {"name": "new-repo"}

CLIでやる場合：
  gh repo create new-repo
  （これだけ。裏側では同じAPIを叩いている）
```

### CLIツールはサービスが提供する

```
GitHub      → gh
Salesforce  → sf
Google      → gogcli
```

ただし全サービスがCLIを提供しているわけではない。
CLIがないサービスはZapierかAPIを直接使う。

### インストールとは

スマホでアプリをダウンロードするのと同じ。

```
スマホ   → App StoreからLINEをダウンロード
パソコン → ターミナルでコマンドを打ってCLIツールを入れる

例）brew install gh
    → これだけでghコマンドが使えるようになる
```

---

## 5. MCP（Model Context Protocol）

### 定義

APIをAI向けに統一した規格。
Anthropicが2024年11月にオープンソースで公開。

### MCPが生まれた背景

MCPが生まれる前、各サービスはそれぞれ独自のAPIを持っていた。
「独自の仕様」とはAPIキーが違うという話ではなく、
**API全体の仕様（エンドポイントのURL・リクエストの形式・認証方式・エラーの返し方）が
サービスごとにバラバラだった**ということ。

```
MCPが生まれる前：
  Salesforce → Salesforce独自のAPI仕様
  Notion     → Notion独自のAPI仕様   → サービスごとに別のコードが必要
  Slack      → Slack独自のAPI仕様

  AIがSalesforceを使いたい → SalesforceのAPI仕様を理解する必要がある
  AIがNotionを使いたい     → NotionのAPI仕様を理解する必要がある
  AIがSlackを使いたい      → SlackのAPI仕様を理解する必要がある

MCPが生まれた後：
  Salesforce → MCP対応
  Notion     → MCP対応  → AIはMCPの共通ルールで話しかけるだけ
  Slack      → MCP対応
```

### MCPの仕様とは何か

MCPの仕様とは「AIとMCPサーバーの間でやり取りする共通ルール」のこと。

```
MCPの仕様で定められていること：
  ・AIがMCPサーバーに何かを頼むときの形式
  ・MCPサーバーがAIに結果を返すときの形式
  ・エラーが起きたときの伝え方
  ・どんな機能が使えるかの伝え方
```

この共通ルールがあるから、Claude CodeはSalesforceだろうとNotionだろうと
同じ方法で話しかけられる。

### 「AIがMCPサーバーに話しかける」の正体

人間が自然言語で指示すると、Claude Codeが自動で構造化された命令に変換してMCPサーバーに送る。
人間が命令の形式を意識する必要はなく、変換はClaude Codeが全部やってくれる。

```
人間がClaude Codeに言う：
「Notionの議事録データベースから今週の議事録を全部取ってきて」

  ↓ Claude Codeが自動で構造化された命令に変換

MCPサーバーへの命令（MCP仕様）：
notion.queryDatabase({
  database_id: "議事録DB",
  filter: { date: { this_week: true } }
})

  ↓ MCPサーバーが翻訳（後述）

NotionのAPIエンドポイントを叩く：
https://api.notion.com/v1/databases/xxx/query
```

### MCPサーバーとは

Claude CodeとAPIの間に立つ「通訳プログラム」。
サービスごとに異なり、そのサービスのAPI専門の通訳になっている。

```
Notion用MCPサーバー     → NotionのAPIを理解している
Slack用MCPサーバー      → SlackのAPIを理解している
Salesforce用MCPサーバー → SalesforceのAPIを理解している
```

### 「翻訳」とは具体的に何か

MCPサーバーが翻訳しているのは「言葉の違い」ではなく「仕様の違い」。
Claude CodeはMCPの共通ルールで話すだけ。
Notionの複雑な独自仕様はMCPサーバーが全部変換してくれる。

```
Claude Codeの言葉（MCP仕様）：
notion.createPage({title: "議事録", content: "..."})

  ↓ MCPサーバーが仕様を変換（翻訳）

NotionのAPIの言葉（Notion独自仕様）：
  送信先 : https://api.notion.com/v1/pages
  認証   : Authorization: Bearer secret_abc123...
  データ : {
    "parent": {"database_id": "xxx"},
    "properties": {
      "title": [{"text": {"content": "議事録"}}]
    },
    "children": [{"paragraph": {"text": [{"content": "..."}]}}]
  }
```

### MCPサーバーは誰が作るか

```
① サービス公式が作る
  例）Notionが自社で @notionhq/notion-mcp-server を作って公開

② サードパーティが作る
  例）有志の開発者がSalesforce用のMCPサーバーを作って公開

③ 自分で作る
  例）社内の独自システム用にMCPサーバーを自作する
```

### MCPの接続方法

Claude Desktopはconfig.json、Claude Codeはsettings.jsonに記述するだけ。
仕組みは同じでファイル名だけ異なる。

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx -y @notionhq/notion-mcp-server"
    }
  }
}
```

**npxコマンドとは：**

```
npx                          → Node.jsのパッケージを実行するコマンド
@notionhq/notion-mcp-server  → Notionが公式で作ったMCPサーバーのプログラム
→ インストール不要でそのまま実行できる
```

### MCPの接続の全体フロー

```
① config.json / settings.jsonにMCPサーバーの設定を記述

② Claude Desktop / Codeが起動するとき
   npxコマンドでMCPサーバーのプログラムを自動起動

③ 人間がClaude Codeに自然言語で指示する
   「Notionのデータベースにこれを追加して」

④ Claude Codeが自動で構造化された命令に変換
   notion.createPage({...})

⑤ MCPサーバーがMCP仕様からNotion独自のAPI仕様に翻訳
   https://api.notion.com/v1/pages に
   NotionのAPIキーを含むリクエストを送る

⑥ Notionがデータを処理して結果を返す

⑦ MCPサーバーがMCP仕様でClaude Codeに返答

⑧ Claude Codeが人間に結果を報告する
```

### CLIとMCPの本質的な違い

```
CLI → 人間が操作することが前提
MCP → AIが自律的に判断して操作することが前提
```

---

## 6. MCPのトークン消費問題：「MCPは常にトークン最小」ではない

### なぜMCPがトークンを食うのか

MCPサーバーが起動するとき、「自分はこんな機能が使えます」という説明書（スキーマ）を
Claude Codeに自動で送り込む。これがトークンを大量に消費する原因。

```
GitHubのMCPサーバーが起動
  ↓
「リポジトリ作成・PR作成・Issue管理・
  コードレビュー・Actions管理・…（93個分）」
という説明書が自動でコンテキストに流れ込む
  ↓
それだけで約55,000トークン消費
  ↓
まだ何もしてないのにトークンが大量に削れている状態
```

### MCPのトークン消費が増える3つのパターン

```
① スキーマの注入
  MCPサーバー接続時にツール定義（説明書）が自動注入される
  例）GitHub MCPサーバー → 93ツール分で約55,000トークン消費

② スナップショットの流れ込み
  Playwright MCPはページ遷移のたびに画面情報がコンテキストに追加される
  → ページを移動するたびにトークンが削れていく

③ ゾンビプロセス
  MCPは常時起動のため、使っていないMCPサーバーが
  バックグラウンドでメモリを圧迫し続ける
```

### 既にCLIがあるツールはCLIを使うべき

```
git / gh         → CLI一発。GitHub MCPサーバー不要
                   （93ツール分のスキーマが丸ごと不要になる）
docker / kubectl → 同じくCLI。MCPサーバーの常時起動が不要
Playwright       → 公式がMCP版とCLI版を両方提供
                   CLI版のほうが明確に高速（実証済み）
Google Workspace → GOG CLI（OAuth）でトークン消費も少ない
```

### 実践：MCPを15個→5個に減らした事例

> 「既にCLIがあるものはCLI、なければMCP。
> この使い分けが正解。こういう地味なチューニングが一番効いてくる。」
> （@SuguruKun_ai）

### MCPが向いているケース

```
✓ OAuth認証や型安全性が必要な場面（Notion・Slack等）
✓ CLIが存在しないサービス
✓ 状態保持や複雑なAPI統合が必要なとき
```

---

## 7. トークン消費・認証・メリデメ比較（修正版）

MCPは設定が簡単な反面、CLIが存在するツールでは
スキーマの注入によりCLIよりトークンを多く消費するケースがある。

| 観点 | API | CLI | MCP |
|---|---|---|---|
| トークン消費 | ✗ 最も多い（コード生成分が余分） | ✓ 少ない（必要なコマンドだけ実行） | △ CLIがあるツールでは多くなる場合も（スキーマ注入） |
| 認証 | APIキーを直接管理（漏洩リスク高い） | OAuth対応が多い（安全性高い） | OAuth or APIキーを${変数}参照 |
| メリット | 自由度最高・あらゆるサービスに対応 | OAuthで安全・Claude Codeが自学・トークン効率が良い | 設定だけで接続・CLIがないサービスに有効 |
| デメリット | コード知識必要・キー管理複雑 | インストール必要・ツールがない場合も | スキーマ注入でトークン消費・対応サービスが限定的 |

---

## 8. サービス別おすすめ接続方法

| サービス | MCP | CLI | API | おすすめ |
|---|---|---|---|---|
| Notion | ✓ Notion MCP | ✗ | ✓ Notion API | **MCP** |
| Gmail/Calendar/Sheets | ✗ | ✓ GOG CLI（OAuth） | ✓ Google API | **CLI（OAuth安全）** |
| Slack | ✓ Slack MCP | ✗ | ✓ Slack API | **MCP** |
| Figma | ✓ Figma MCP | ✗ | ✓ Figma API | **MCP** |
| freee | ✓ freee MCP | ✗ | ✓ freee API | **MCP** |
| Salesforce | ✗ | ✓ sf CLI | ✓ SF API | **CLI** |
| GitHub | ✓ GitHub MCP | ✓ gh | ✓ GitHub API | **CLI**（MCPは93ツール分のスキーマで重い） |
| Playwright | ✓ MCP版あり | ✓ CLI版あり | ✓ API | **CLI**（CLI版が明確に高速） |

---

## 9. 全体比較表

| | API | CLI | Zapier | MCP |
|---|---|---|---|---|
| 種別 | 仕組み | ツール | ツール | 規格 |
| 対象 | エンジニア | エンジニア | 非エンジニア | AI |
| 操作方法 | コードを書く | コマンドを打つ | GUIでポチポチ | 設定1行 |
| 難易度 | ★★★ | ★★ | ★ | ★ |
| 裏側 | API本体 | APIを叩いてる | APIを叩いてる | APIを叩いてる |
| 人間の操作 | 必要 | 必要 | 必要 | 不要（AIが自律判断） |

---

## 10. 実務での選び方（最終版）

```
そのサービスのCLIがある？
  → YES：CLIを使う（トークン効率が良い）
  → NO：MCPがある？
       → YES：MCPを使う（設定だけで繋がる）
       → NO：Zapierで繋げられる？
            → YES：Zapierを使う（GUIで設定）
            → NO：APIを直接使う（コードを書く）
```

**判断基準のポイント：**

```
CLIがある              → CLI優先（トークン消費が少ない）
CLIがなくMCPがある     → MCP（特にOAuth認証が必要なNotion・Slack等）
どちらもなし           → API（Claude Codeがコードを書いてくれる）
```

公式MCPサーバー一覧：https://modelcontextprotocol.io

---

## 11. まとめ：3行で言うと

1. **全部の根っこはAPI。** CLIもZapierもMCPも裏側ではAPIを叩いている。
2. **違いは「誰が使うか」。** エンジニア→CLI、非エンジニア→Zapier、AI→MCP。
3. **MCPは万能ではない。** CLIがあるツールはCLI優先。MCPはCLIがないサービスや複雑な認証が必要な場面で真価を発揮する。
