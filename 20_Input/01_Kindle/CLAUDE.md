# 20_Input/01_Kindle コンテキスト

## Obsidian 設定（Kindle Highlights プラグイン）

- **設定**：Obsidian → 設定 → コミュニティプラグイン → **Kindle Highlights** → **Folder**
- **正本パス**：`20_Input/01_Kindle`（Vault ルートからの相対。先頭 `/` なし）
- **同期**：左サイドバーの Kindle アイコン → **Sync now**（起動時同期はプラグイン設定の `syncOnBoot` で ON 可）
- **注意**：以前 `30_Input/Kindle` 等と食い違うと、ここに **本の md が増えない**。`.obsidian/plugins/obsidian-kindle-plugin/data.json` の `highlightsFolder` と一致させる。

## 手順（初回・「今後だけ」・過去本を出したくないとき）

プラグイン公式 README では、**以降の同期は intelligent diff で新規ハイライト中心**、**Ignored books で本単位に除外**とある（[hadynz/obsidian-kindle-plugin README](https://github.com/hadynz/obsidian-kindle-plugin)）。

### A. 最初に一度やること（保存先の固定）

1. Obsidian → **設定** → **コミュニティプラグイン** → **Kindle Highlights**
2. **Highlights folder** を **`20_Input/01_Kindle`** にする（本Vaultのルート相対）
3. **Amazon region** が自分のアカウント（例：Japan）と一致しているか確認
4. 左サイドバーの **Kindle** アイコン → **Sync**（またはコマンドパレットから同期）

→ 初回はクラウド上のハイライトがある本が **まとめて取り込まれる**のが通常（Amazon側にデータがある限り）。

### B. 「この本は Obsidian に載せたくない」（同期対象から外す）

**方法1（おすすめ）**：ファイル一覧で、対象の本のノートを **右クリック**

- **Ignore this book** … 以降の同期でその本を**スキップ**（リストは `Ignored books` に入る）
- **Ignore and delete this book** … 上記に加え、Vault 上のそのノートを**ゴミ箱へ**（確認ダイアログあり）

**方法2**：設定の **Ignored books** に、**タイトルの一部**を1行ずつ（**部分一致・大文字小文字無視**）。複数本あるなら行を増やす。

→ **Amazonアカウントを作り直す必要はない**。除外はプラグイン側の設定で足りる。

### C. 「今後つけたハイライトだけ追従したい」

1. 初回のフル取り込みは **一度受け入れる**（または B で不要な本だけ先に除外してから Sync）
2. 以降は定期的に **Sync** を押すだけ。README 上は **既存ノートの手編集を押し戻さず**、**新規ハイライトを diff で取り込む**動き

※ 挙動の細部は Amazon 側の表示・本の種別・プラグインバージョンで差が出る場合がある。おかしいときはプラグインの **アクティビティログ**をコピーして調査する。

### D. セキュリティ（Amazonログイン方式を使う場合）

README のとおり、Obsidian 経由で Amazon にログインすると **セッションが他プラグインからも触れうる**。**同期後にログアウト**するか、**My Clippings.txt アップロード方式**でオフライン寄せにする、などの選択がある。

## 役割
Kindleハイライトの自動同期先。直接編集・整理はせず、定期的に処理して `10_Culture/` や各ドメインへ洞察を転記する。

## 運用ルール
- **直接編集しない** — 自動同期されたまま保持する
- **定期処理** — Claude Codeによる随時バッチ処理でハイライトから洞察を抽出し、ドメインフォルダへ転記する
- **元ファイルは保持** — NotebookLMのソースとしても活用する

## 処理フロー
```
20_Input/01_Kindle/ → Claude Code処理 → 洞察・学び・アクションをドメインフォルダへ
                                例: ビジネス書   → 01_Work/ or 10_Culture/
                                    キャリア本   → 03_Career/
                                    AI本        → 04_AI/
                                    健康・競技本 → 09_Athlete/
```

## Claude Codeへの指示方針
- ハイライトを処理する際は「自分のVaultのどの文脈で使えるか」を判断して転記すること
- ハイライトをそのまま転記するのではなく、「学び・実践アクション」に変換すること
- 書籍全体のテーマと個別ハイライトの関係性を踏まえて整理すること
- 処理後は `10_Culture/` に読書ログのサマリーを作成すること
