#!/bin/bash
# =============================================================
# LifeOS ローカル自動化インストールスクリプト
# 対象: P1-1（情報収集）/ life-reminder（食事・トレ）/ life-summary（夜サマリ）
# 実行方法（ターミナルで）:
#   bash ~/Library/CloudStorage/.../ObsibianVault/05_Life/50_AI自動化/scripts/install.sh [target]
#   target: all（省略時）| p1-1 | reminder | summary
# =============================================================

set -euo pipefail

TARGET="${1:-all}"
VAULT="/Users/kousakanaoya/Library/CloudStorage/GoogleDrive-naoya.kousaka.biz@gmail.com/マイドライブ/ObsibianVault"
SCRIPTS_SRC="$VAULT/05_Life/50_AI自動化/scripts"
SCRIPTS_DEST="$HOME/scripts"
PLIST_DIR="$HOME/Library/LaunchAgents"
CONFIG_DIR="$HOME/.config/lifeos"
APP_DIR="$HOME/Applications"

mkdir -p "$SCRIPTS_DEST" "$PLIST_DIR" "$CONFIG_DIR" "$APP_DIR"

# ── P1-1（情報収集 06:32）─────────────────────────────────
install_p1_1() {
  local LABEL="com.lifeos.p1-1-collect"
  local WRAPPER_APP="$APP_DIR/LifeOS_P1-1.app"
  local WRAPPER_SRC="$SCRIPTS_SRC/p1-1-launchd-wrapper.applescript"

  echo "──────────────────────────────────────────"
  echo " P1-1 情報収集 インストール"
  echo "──────────────────────────────────────────"

  cp "$SCRIPTS_SRC/p1-1-collect.sh" "$SCRIPTS_DEST/p1-1-collect.sh"
  cp "$SCRIPTS_SRC/p1-1-collect.py" "$SCRIPTS_DEST/p1-1-collect.py"
  chmod +x "$SCRIPTS_DEST/p1-1-collect.sh" "$SCRIPTS_DEST/p1-1-collect.py"
  echo "✓ スクリプト設置"

  if command -v osacompile >/dev/null 2>&1 && [ -f "$WRAPPER_SRC" ]; then
    osacompile -o "$WRAPPER_APP" "$WRAPPER_SRC" >/dev/null 2>&1 || true
    echo "✓ wrapper app 生成"
  fi

  if [ ! -f "$CONFIG_DIR/p1-1.env" ]; then
    cp "$SCRIPTS_SRC/p1-1.env.example" "$CONFIG_DIR/p1-1.env"
    echo "✓ env ひな形設置: $CONFIG_DIR/p1-1.env（編集して SLACK_BOT_TOKEN を入力してください）"
  fi

  local PLIST_DEST="$PLIST_DIR/$LABEL.plist"
  cp "$SCRIPTS_SRC/com.lifeos.p1-1-collect.plist.template" "$PLIST_DEST"
  launchctl unload "$PLIST_DEST" 2>/dev/null || true
  launchctl load -w "$PLIST_DEST"
  echo "✅ P1-1 登録完了（次回実行: 翌 06:32 JST）"
}

# ── life-reminder（食事・トレ通知）────────────────────────
install_reminder() {
  echo "──────────────────────────────────────────"
  echo " life-reminder インストール"
  echo " 時刻: 朝食07:30 / 昼12:00 / 補食15:30 / 夕食19:00 / トレ06:00"
  echo "──────────────────────────────────────────"

  cp "$SCRIPTS_SRC/life-reminder.sh" "$SCRIPTS_DEST/life-reminder.sh"
  chmod +x "$SCRIPTS_DEST/life-reminder.sh"
  echo "✓ スクリプト設置"

  for TYPE in breakfast lunch snack dinner training; do
    local LABEL="com.lifeos.reminder-$TYPE"
    local PLIST_DEST="$PLIST_DIR/$LABEL.plist"
    cp "$SCRIPTS_SRC/com.lifeos.reminder-${TYPE}.plist.template" "$PLIST_DEST"
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    launchctl load -w "$PLIST_DEST"
    echo "✓ $LABEL 登録完了"
  done

  echo "✅ life-reminder 5件 登録完了"
  echo "   トレーニング時刻を変更する場合:"
  echo "   $PLIST_DIR/com.lifeos.reminder-training.plist を編集 → launchctl reload"
}

# ── life-summary（夜サマリ 21:00）─────────────────────────
install_summary() {
  local LABEL="com.lifeos.life-summary"

  echo "──────────────────────────────────────────"
  echo " life-summary インストール（21:00）"
  echo "──────────────────────────────────────────"

  cp "$SCRIPTS_SRC/life-summary.sh" "$SCRIPTS_DEST/life-summary.sh"
  chmod +x "$SCRIPTS_DEST/life-summary.sh"
  echo "✓ スクリプト設置"

  local PLIST_DEST="$PLIST_DIR/$LABEL.plist"
  cp "$SCRIPTS_SRC/com.lifeos.life-summary.plist.template" "$PLIST_DEST"
  launchctl unload "$PLIST_DEST" 2>/dev/null || true
  launchctl load -w "$PLIST_DEST"
  echo "✅ life-summary 登録完了（次回実行: 本日 or 翌 21:00）"
}

# ── 実行 ─────────────────────────────────────────────────
case "$TARGET" in
  p1-1)     install_p1_1 ;;
  reminder) install_reminder ;;
  summary)  install_summary ;;
  all)
    install_p1_1
    echo ""
    install_reminder
    echo ""
    install_summary
    echo ""
    echo "══════════════════════════════════════════"
    echo "✅ 全ジョブ インストール完了"
    echo "══════════════════════════════════════════"
    echo ""
    echo "テスト配信:"
    echo "  bash $SCRIPTS_DEST/life-reminder.sh breakfast"
    echo "  bash $SCRIPTS_DEST/life-summary.sh"
    echo ""
    echo "登録確認:"
    echo "  launchctl list | grep com.lifeos"
    ;;
  *)
    echo "Usage: $0 [all|p1-1|reminder|summary]"
    exit 1
    ;;
esac
