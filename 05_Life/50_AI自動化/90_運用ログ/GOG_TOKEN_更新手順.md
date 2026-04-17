---
date: 2026-04-17
type: playbook
domain: life
status: active
source: claude-code
generated_at: 2026-04-17
reviewed: false
---

# GOG_TOKEN_B64 更新手順

## いつ更新が必要か

朝ブリーフィングの「予定」欄に以下が表示されたとき：

> なし（⚠️ 取得失敗 — GOG_TOKEN_B64 の期限切れの可能性あり）

## 更新手順（Mac で実行）

```bash
# 1. トークンをエクスポートしてクリップボードへ
gog auth tokens export naoya.kousaka.biz@gmail.com --output /tmp/gog-token.json
cat /tmp/gog-token.json | base64 | pbcopy
rm /tmp/gog-token.json
```

```
# 2. GitHub Secrets を更新
# https://github.com/naoyakousakabiz/ObsidianVault/settings/secrets/actions
# → GOG_TOKEN_B64 を上書き
```

## トークンが失効する主な原因

- Google アカウントのパスワード変更
- 6ヶ月以上未使用（Google のポリシー）
- OAuth 同意の取り消し

## credentials.json の更新が必要な場合

OAuth クライアント自体を再作成した場合のみ必要。

```bash
cat ~/Library/Application\ Support/gogcli/credentials.json | base64 | pbcopy
# → GitHub Secrets の GOG_CREDENTIALS_B64 を上書き
```
