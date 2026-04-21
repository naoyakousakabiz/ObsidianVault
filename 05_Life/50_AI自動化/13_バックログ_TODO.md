---
date: 2026-04-17
type: playbook
domain: life
status: active
source: human
tags: [automation, backlog, todo]
---

# 日常AI自動化 — バックログ（ゼロベース棚卸し版）

**運用の正本:** `10_日常AI自動化_運用設計.md`  
**いまの優先度サマリ:** `12_進行スナップショット.md`  

---

## 0. 現状の前提（読み替え）

| 論点 | 整理 |
|------|------|
| **クラウド一本化** | **済み**とみなす。本番経路は **GitHub Actions**（`p1-1-collect` / `morning-briefing` / `life-reminder` / `daily-note-create`）。残るのは **ローカル launchd が重複していないかの確認**だけ。 |
| **3ch テスト配信** | **済み**とみなす。トラブル時のみ再テスト。 |
| **いまの本丸** | **P1-2 朝ブリーフィング**（`morning-briefing.yml`）の **信頼性検証**（gog / カレンダー / Slack）。 |

---

## 1. よくある誤解（運用）

| 項目 | 事実 |
|------|------|
| 朝の「おはよう」 | **Cursor** 側。`10_` §10.1 と `04_AI/01_運用/01_ツール役割と運用.md` の「毎日の運用」。 |
| 作業詳細ログ | **自動ではない**（`append-shell-history-to-daily.sh` は手動 or 自分で launchd）。 |

---

## 2. A. 情報収集（P1-1）と X — バックログ一覧

コード: `scripts/p1-1-collect.py`・`p1-1-collect.yml`

| # | 項目 | 内容 |
|---|------|------|
| A1 | X API Basic（有料） | Recent search に **Basic tier** が前提。未加入時はスキップ表示。 |
| A2 | `X_BEARER_TOKEN` | Secrets / `p1-1.env`。未設定なら X はスキップ。 |
| A3 | `X_ACCOUNTS` | コード内リストの見直し。 |
| A4 | `X_MIN_LIKES` / `X_DAILY_LIMIT` | ノイズと件数の調整。 |
| A5 | Slack 表示 | `#life-info` の【X】ブロックの読みやすさ。 |
| A6 | エラー時 | 402 等の扱い（ログ・静かにスキップ等）。 |
| A7 | 意思決定 | 有料を続けるか、RSS/手動に寄せるか。 |

---

## 3. B. 残タスク（漏れ防止チェックリスト）

### 本番の信頼性（最優先）

- [ ] **`morning-briefing.yml`**: `workflow_dispatch` とスケジュール実行のログ確認。カレンダー未取得時に **誤った「空表示」にならない**こと。`#life-briefing` の内容レビュー。

### メンテ（一度でよいことが多い）

- [ ] **Git push**: Vault → `main`。  
- [ ] **Secrets**: 未使用 `P13_SLACK_CHANNEL_ID` 削除（任意）。  
- [ ] **旧 life-summary**: `com.lifeos.life-summary` の plist が残っていれば削除。  
- [ ] **二重運用**: `com.lifeos.p1-1-collect` / `morning-briefing` / `reminder-*` が **GitHub と両方**動いていないか。不要な launchd は停止。

### 任意

- [ ] **`install.sh eod-push`**: GitHub バックアップ用。  
- [ ] **`append-shell-history` + launchd**: 終業時にターミナル欄を自動で埋めたい場合のみ。

---

## 4. C. 通知の粒度（参照用）

| レイヤ | 例 |
|--------|-----|
| Slack チャンネル | 本自動化の主出力（3ch + 廃止済みの夜サマリ以外）。 |
| OS リマインダー / カレンダー | Vault 外。必要なら別途。 |
| `append-shell-history` | **通知なし**・デイリー追記のみ。 |

---

## 5. D. Claude Code 依頼テンプレ（コピペ用）

**ライフリマインダーの中身・文言の改修は依頼に含めない。** 朝ブリーフィング検証と棚卸しが主。

```text
ObsidianVault の日常AI自動化について、次をゼロから棚卸しして実施してほしい。

正本:
- 05_Life/50_AI自動化/10_日常AI自動化_運用設計.md
- 05_Life/50_AI自動化/12_進行スナップショット.md
- 05_Life/50_AI自動化/13_バックログ_TODO.md
- .github/workflows/morning-briefing.yml, p1-1-collect.yml, life-reminder.yml, daily-note-create.yml

前提:
- クラウド本番は GitHub Actions に寄せ済み。3ch のテスト配信は完了済み。
- 残りの本丸は P1-2 朝ブリーフィング（morning-briefing）の信頼性検証。

やること:
1. morning-briefing.yml と 05_Life/50_AI自動化/scripts/morning_briefing.sh（または呼び出し先）を読み、カレンダー取得失敗時の挙動・ログ・終了コードを整理する。ユーザーが Actions のログだけで切り分けできるように、不足があれば改善案を出す（秘密は書かない）。
2. ローカル launchd と GitHub が二重になっていないか、ドキュメントに沿って確認手順を短く書く。
3. 13_ §3 のチェックリストを、実施結果に合わせて更新する案を出す。
4. X 連携・eod-push・append-shell はバックログ扱い。触るなら 13_ §2 を参照。

コミットメッセージ案も出して。
```

---

## E. 索引

本ファイルは `05_Life/50_AI自動化/00_索引.md` に載せる。
