#!/bin/bash
# =============================================================
# P1-1 情報収集 + Daily事前作成
# 実行: 毎朝 06:32 JST（launchd 経由）
# 設置先: ~/scripts/p1-1-collect.sh
# 設置方法: 05_Life/50_AI自動化/scripts/install.sh を実行
# =============================================================

set -euo pipefail

VAULT="/Users/kousakanaoya/Library/CloudStorage/GoogleDrive-naoya.kousaka.biz@gmail.com/マイドライブ/ObsibianVault"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON_COLLECTOR="$SCRIPT_DIR/p1-1-collect.py"
TODAY=$(TZ=Asia/Tokyo date +%Y-%m-%d)
YESTERDAY=$(TZ=Asia/Tokyo date -v-1d +%Y-%m-%d)
DAILY="$VAULT/80_Journal/01_Daily/$TODAY.md"
COLLECT_DIR="$VAULT/20_Input/05_日次情報収集"
COLLECT_FILE="$COLLECT_DIR/${TODAY}_collect.md"
PREVIOUS_COLLECT_FILE="$COLLECT_DIR/${YESTERDAY}_collect.md"
LOG_DIR="$VAULT/05_Life/50_AI自動化/90_運用ログ"
RUN_LOG="$LOG_DIR/${TODAY}_p1-1-run.log"
ERR_LOG="$LOG_DIR/${TODAY}_automation-error.md"
COLLECTOR_LOG="$LOG_DIR/${TODAY}_p1-1-collector.log"
LOCK_DIR="$LOG_DIR/p1-1.lock"
ENV_FILE="$HOME/.config/lifeos/p1-1.env"

export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.npm/global/bin:$HOME/.local/bin:$PATH"

if [ -f "$ENV_FILE" ]; then
  # Allow launchd/manual runs to share the same Slack token source.
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

mkdir -p "$COLLECT_DIR" "$LOG_DIR"
cd "$VAULT"

echo "=== P1-1 開始 $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S') JST ===" >> "$RUN_LOG"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] 既存実行あり: 今回はスキップ" >> "$RUN_LOG"
  echo "=== P1-1 終了 $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S') JST ===" >> "$RUN_LOG"
  exit 0
fi

cleanup() {
  rm -rf "$LOCK_DIR"
}
on_term() {
  echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] SIGTERM受信: 実行を中断" >> "$RUN_LOG"
  cleanup
  exit 143
}
trap cleanup EXIT INT
trap on_term TERM

if [ ! -f "$DAILY" ]; then
  TEMPLATE="$VAULT/99_System/Templates/Daily.md"
  if cp "$TEMPLATE" "$DAILY" 2>> "$RUN_LOG"; then
    LC_ALL=C sed -i '' 's|<% tp.date.now("YYYY-MM-DD") %>|'"$TODAY"'|g' "$DAILY"
    echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] Daily作成: $DAILY" >> "$RUN_LOG"
  else
    echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] Daily作成失敗（権限不足の可能性）: $DAILY" >> "$RUN_LOG"
  fi
else
  echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] Daily既存: スキップ" >> "$RUN_LOG"
fi

if [ ! -f "$PYTHON_COLLECTOR" ]; then
  echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] 収集スクリプト未検出: $PYTHON_COLLECTOR" >> "$RUN_LOG"
  exit 1
fi

set +e
python3 "$PYTHON_COLLECTOR" \
  --date "$TODAY" \
  --output "$COLLECT_FILE" \
  --previous-file "$PREVIOUS_COLLECT_FILE" \
  > "$COLLECTOR_LOG" 2>&1
EXIT_CODE=$?
set -e

if [ -s "$COLLECTOR_LOG" ]; then
  while IFS= read -r line; do
    echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] $line" >> "$RUN_LOG"
  done < "$COLLECTOR_LOG"
fi

echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] collector 終了コード: $EXIT_CODE" >> "$RUN_LOG"

if [ $EXIT_CODE -ne 0 ]; then
  cat > "$ERR_LOG" <<ERREOF
---
timestamp: $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S') JST
task_id: p1-1-collect-0632
error_summary: Python collector が非ゼロ終了コードで終了（詳細は _p1-1-run.log / _p1-1-collector.log を参照）
fallback_action: 手動で RSS を確認し 20_Input/05_日次情報収集/ に保存する
status: unresolved
---
ERREOF

  if [ ! -f "$COLLECT_FILE" ]; then
    cat > "$COLLECT_FILE" <<EOF
---
date: $TODAY
type: rss-collect
domain: life
status: active
source: auto-sync
tags: [fallback, collect]
---

# 情報収集 $TODAY（フォールバック）

Python collector が失敗したため、要約なしのフォールバックファイルを生成。

- 実行時刻: $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S') JST
- 状態: 収集処理失敗（要再実行）
- エラーログ: \`05_Life/50_AI自動化/90_運用ログ/${TODAY}_automation-error.md\`

## 次アクション

1. collector log を確認して再実行
2. もしくは手動で主要ソースを確認し、本ファイルへ追記
EOF
    echo "[$(TZ=Asia/Tokyo date '+%H:%M:%S')] fallback collect file created: $COLLECT_FILE" >> "$RUN_LOG"
  fi
fi

echo "=== P1-1 終了 $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S') JST ===" >> "$RUN_LOG"

exit "$EXIT_CODE"
