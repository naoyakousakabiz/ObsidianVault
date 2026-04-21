---
date: 2026-04-21
type: playbook
domain: life
status: active
source: human
tags: [security, automation, twitterapi, x]
---

# twitterapi.io API キー：流出が疑われるとき／再開

Vault や GitHub の「収集オフ」設定は、**自分の自動化を止める**ためのもの。**キーそのものを無効にしない限り、キーを知っている第三者は別経路から API を叩けます。** 疑いがあるときは **プロバイダ側でキーを失効**することが必須です。

---

## いつこの手順を使うか

| 状況 | やること |
|:--|:--|
| キーがチャット・ログ・公開リポジトリに載ったかもしれない | 下記「流出時チェックリスト」を実施 |
| 単にしばらく X 収集を止めたいだけ | このファイルではなく、`.github/workflows/p1-1-collect.yml` の `P11_X_COLLECTION_ENABLED` と `scripts/p1-1-collect.py` の `X_COLLECTION_ENABLED` を参照 |
| キーを取り替えたあと X をまた動かす | 下記「再開チェックリスト」 |

---

## 流出時チェックリスト（上から順に）

1. **twitterapi.io にログイン**し、該当の API キーを **無効化・削除**する（ダッシュボードの表記はサービス更新で変わることがある。「API Key」「Revoke」「Delete」など）。
2. **新しいキーを発行**する（可能なら「ローテーション」や「新規キー作成」）。
3. **GitHub** → 対象リポジトリ → **Settings → Secrets and variables → Actions** → `TWITTERAPI_IO_KEY` を **Edit** し、**新キーだけ**を保存する（旧キーはもう使わない）。
4. **同じキーを貼っていた場所**を思い出し、削除・差し替えする（下記「棚卸しの例」）。
5. 必要なら **twitterapi.io の利用履歴・請求**を確認し、不審な呼び出しがないか見る。

**Vault 内には API キー本体を書かない。** 正は GitHub Secrets（と、ローカルなら自分の環境変数・キーチェーン）だけ。

### 再発行（Rotate）直後にやること

1. **GitHub** → 対象リポジトリ → **Settings → Secrets and variables → Actions** → **`TWITTERAPI_IO_KEY`** を **新しいキーに更新**する。
2. **X 収集がオフ**（`P11_X_COLLECTION_ENABLED: "false"`）のあいだは、スクリプトは **twitterapi.io を呼ばない**ため、**キーが古いままでも Actions は「キー誤り」で落ちない**（再開して初めて検知される）。再開前に Secrets を揃えておくと安全。

---

## GitHub で「キーが間違っている」はどう見えるか

- **P1-1（`p1-1-collect.py`）は** `https://api.twitterapi.io/...` へ **GitHub Actions のランナーから直接 HTTPS** する。**このワークフローにトンネル設定はない。** キー・ネットワークの問題は **twitterapi.io 側の応答**か **Secrets の値**で決まる。トンネル不調を GitHub に直してもらう、という種類の話では通常ない。
- **キーが無効／誤り**のとき、X 取得部分はログの **stderr** に例えば次のような行が出る（正確な文言は API 側次第）:
  - `X取得失敗: HTTP 401`（認証エラーに近いコードのとき）
  - `X API エラー: …`（JSON の `msg` が返るとき）
- **見る場所:** リポジトリ → **Actions** → 該当 Run → **Run P1-1 collector** ステップを開く。

### 注意（ジョブが緑でも X だけ失敗していることがある）

スクリプトは **RSS か YouTube が1件でも取れていれば**、X が失敗しても **終了コード 0（成功）** になる場合がある。その場合も **同じステップのログ stderr** に `X取得失敗` などが残る。**失敗の赤 X を見るだけだと見落としうる**ので、再開後はログ本文を確認する。

---

## 手順の説明（わかりやすく）

### A. プロバイダ側で「古いキーを死なせる」

流出の疑いがあるキーは、**もう信用しない**。twitterapi.io の管理画面で、そのキーを無効化または削除する。ここをやらないと、**別の人がそのキーで課金され続ける**可能性がある。

### B. 「新しい鍵」だけを本番に渡す

新キーを発行したら、**GitHub の `TWITTERAPI_IO_KEY` を新しい値に更新**する。次回の Actions から新キーだけが使われる。旧キーはどこにも残さない。

### C. 漏れていた場所を片付ける

キーを **Slack・メール・スクリーンショット・別 PC のメモ・fork したリポジトリ**に貼っていないか思い出し、消せるものは消す。完全には追えない場合でも、**A で旧キーを無効化**しておけば、漏れていたコピーは使えなくなる。

---

## 棚卸しの例（思い出し用）

- GitHub Actions の Secrets（本番）
- ローカル `~/.zshrc` や `launchd` 用の plist、シェルスクリプト内の `export`
- パスワードマネージャのメモ欄
- 過去のチャット・チケット・Run のログ（キーがマスクされていない場合）

---

## 再開チェックリスト（X 収集をまた動かすとき）

キー差し替えが終わった**あと**、次を **true / 有効**に戻す（現状はコスト・運用で止めている想定）。

1. **GitHub Actions**  
   `.github/workflows/p1-1-collect.yml` の `env` で  
   `P11_X_COLLECTION_ENABLED: "true"` にする（またはこの行を削除し、下記 2 と整合させる）。
2. **スクリプトのデフォルト**（ローカル実行や env 未設定時）  
   `05_Life/50_AI自動化/scripts/p1-1-collect.py` の `X_COLLECTION_ENABLED = True` にする。
3. **動作確認**  
   GitHub で `p1-1-collect` を **workflow_dispatch** 手動実行し、ログに X 件数が出ること・Slack に想定どおり届くことを確認。

RSS / YouTube だけ動いていて X だけ 0 件のときは、上記 1〜2 と `TWITTERAPI_IO_KEY` の有無を疑う。

---

## 関連ファイル

| 内容 | パス |
|:--|:--|
| P1-1 収集スクリプト | `05_Life/50_AI自動化/scripts/p1-1-collect.py` |
| 本番ワークフロー | `.github/workflows/p1-1-collect.yml` |
| Secrets 一覧 | `11_日常AI自動化_実装指示書.md` の §1 |
