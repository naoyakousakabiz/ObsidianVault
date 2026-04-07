# 20_Input/02_Clippings コンテキスト

## ブラウザ拡張（Obsidian Web Clipper）の設定手順

### トラブル：`Unable to find a vault for the URL obsidian://...&vault=20_Input%2F02_Clippings`

**原因**：URI の `vault=` に **フォルダパス**（`20_Input/02_Clippings`）を入れている。**`vault=` には Obsidian の Vault 名だけ**を入れる（左下または「別の Vault を開く」一覧に出る**Vault の表示名**。フォルダではない）。

- **誤**：`vault=20_Input/02_Clippings`
- **正**：`vault=ObsibianVault`（例：あなたの環境の実際の Vault 名に合わせる）

保存先フォルダは **`file=` のパス**、またはテンプレートの **Note path / Folder** で `20_Input/02_Clippings/ノート名` のように指定する。**「Vault 名」と「保存フォルダ」は別フィールド**。

---

**よくある誤解**：拡張のトップ画面に「デフォルト保存先」だけが無いことが多い。**公式 Web Clipper は「General で Vault を登録」し、保存フォルダは多くの場合「テンプレート」側で指定する**（フォーラムでも同様の説明）。

1. **Obsidian でこの Vault を開いたまま**にしておく（Clipper は `obsidian://` でVaultに飛ばすため）。
2. ブラウザで **Obsidian Web Clipper** → **オプション**。
3. **General（または Vaults）**：このVaultの**表示名**（Obsidian左下・Vault切り替えで見える名前）を登録し、Clip時に選べるようにする。
4. **Templates（テンプレート）**：よく使うテンプレートを開き、**ノートの保存先フォルダ**（表記例：`Folder` / `Path` / `Note path` / プロパティ内の path）に次を入れる。
   - `20_Input/02_Clippings`
   - Vault名は書かない。先頭の `/` は付けない。区切りは `/`。
5. テンプレートに **どの Vault に保存するか** の選択がある場合、手順3で登録したVaultを選ぶ。
6. **動作確認**：任意のページで Clip → `20_Input/02_Clippings` に **新規 `.md`** が増えるか見る。
7. 別フォルダに落ちる：**別テンプレ**や **Highlights / 規則（Rules）** でパスが上書きされていないか確認。

**Vault 内のこのフォルダ**：初期は `CLAUDE.md` と `_processed_log.md` だけでも正常。**クリップを一度もしていなければ `.md` が他に無いのは自然**。

## 役割
Obsidian Webクリッパーによる自動保存の受け皿。直接編集・整理はせず、定期的に処理してドメインフォルダへ流す。

## 運用ルール
- **直接編集しない** — 自動入力されたまま保持する
- **定期処理** — Claude Codeによる週次または随時バッチ処理で洞察を抽出し、ドメインフォルダへ転記する
- **元ファイルは保持** — 転記後も削除しない（ソースとして残す）

## 処理フロー
```
20_Input/02_Clippings/ → Claude Code処理 → 洞察・要点をドメインフォルダへ
                                   例: ビジネス記事 → 01_Work/
                                       キャリア記事 → 03_Career/
                                       AI記事      → 04_AI/
                                       健康記事    → 09_Athlete/
```

## Claude Codeへの指示方針
- クリッピングを処理する際は「洞察・アクション・保存先ドメイン」を判断して転記すること
- 単純な記事要約にとどめず、「自分のVaultでどう使えるか」の観点で整理すること
- 保存先が不明な場合は`00_Inbox/`に置いてユーザーに判断を仰ぐこと
