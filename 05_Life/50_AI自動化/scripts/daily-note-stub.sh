#!/usr/bin/env bash
# daily-note-stub.sh — 指定日のデイリー骨子を1ファイルに書き出す（上書きしない）
# 使い方: TODAY=YYYY-MM-DD VAULT=/path/to/Vault bash daily-note-stub.sh
# 環境変数 VAULT 省略時はカレントディレクトリ。

set -euo pipefail

TODAY="${TODAY:-$(TZ=Asia/Tokyo date +%Y-%m-%d)}"
ROOT="${VAULT:-.}"
REL="80_Journal/01_Daily/${TODAY}.md"
OUT="${ROOT%/}/${REL}"

if [[ -f "$OUT" ]]; then
  echo "exists: $OUT — skip"
  exit 0
fi

mkdir -p "$(dirname "$OUT")"

cat > "$OUT" << EOF
---
date: ${TODAY}
type: log
domain: journal
status: active
source: auto-sync
tags: []
---

# ${TODAY}

## 今日やること

### 本業
1.
2.
3.

### RINGBELL
1.
2.
3.


### 学習
1.
2.


### 運動 / トレーニング
1.
2.


### その他
1.
2.


---

## メモ・気づき
- 

---

## 状態ルール（必要なら見る）
（完了） / （進行中） / （保留） / （中止）

---

## 作業詳細ログ（任意）

ここは **1日の補足記録** 用です（ターミナルや Cursor のメモなど）。**上の「メモ・気づき」と役割が近いが、長いログはこちらに逃がしてよい。** 将来の自分向けのログとして使ってください。

### ターミナル（zsh）で打ったコマンド

<!-- AUTO_SHELL_START -->
（まだ追記されていません。Mac で Vault のルートに移動し、\`bash 05_Life/50_AI自動化/scripts/append-shell-history-to-daily.sh\` を実行すると、直近のコマンドが入ります。）
<!-- AUTO_SHELL_END -->

### Cursor（エディタ）でのやり取り

- **自動では入りません。** Cursor の会話をファイルに自動で流し込む公式機能はありません。
- **書き方の例:** その日に「決めたこと」「調べたこと」「次にやること」を、箇条書きで3行でもOKです。
- 長いチャットは、**要だけコピーして貼る**運用で十分です。

- 
EOF

echo "wrote: $OUT"
