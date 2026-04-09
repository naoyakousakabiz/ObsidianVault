---
id: calendar-today
version: 1
domains: [google, calendar]
requires:
  - gog が認証済み（`gog gmail search` 等が成功する状態）
  - 予定取得に使う Google アカウント（未指定なら既定 or `GOG_ACCOUNT`）
related: [gogcli, morning-briefing, post-meeting]
---

# /calendar-today — 今日の予定（gog calendar）

## これは何か

`gog calendar events --today` を使い、**今日の予定**を取得して読みやすく整形する。

## 使い方（ユーザー向け）

- 「`calendar-today`。アカウント: xxx@gmail.com（任意）」のように依頼する

## エージェントの進め方

1. アカウントが指定されていればそれを使う。無ければ `GOG_ACCOUNT` があればそれ、無ければ既定アカウント。
2. まずは **読み取りのみ**で取得する（変更系コマンドは禁止）。
3. 予定が 0 件なら「0件」と返す。

## 実行（エージェント）

以下を実行して結果を整形して返す。

- コマンド（推奨）:
  - `gog calendar events --today --max 50 -p`
  - 必要に応じて `--weekday` を追加

## 出力フォーマット

- 今日の日付（ローカル）
- 予定一覧（時刻 / タイトル / カレンダー名またはID / 場所 / 参加者（取れる範囲））
- 「終日」イベントは区別して表示

