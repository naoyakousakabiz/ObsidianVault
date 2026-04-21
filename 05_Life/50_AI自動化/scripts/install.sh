#!/bin/bash
# =============================================================
# LifeOS ローカル自動化インストールスクリプト
# 対象: P1-1（情報収集）/ life-reminder（食事・トレ）
# 実行方法（ターミナルで）:
#   bash ~/Library/CloudStorage/.../ObsibianVault/05_Life/50_AI自動化/scripts/install.sh [target]
#   target: all（省略時）| p1-1 | reminder | eod-push
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
  echo " 時刻: 朝食06:00 / 昼11:30 / 補食15:30 / 夕食18:30 / 仕事終19:00 / トレ20:00 / 音声22:00 / 就寝22:30"
  echo "──────────────────────────────────────────"

  cp "$SCRIPTS_SRC/life-reminder.sh" "$SCRIPTS_DEST/life-reminder.sh"
  chmod +x "$SCRIPTS_DEST/life-reminder.sh"
  echo "✓ スクリプト設置"

  if [[ -f "$VAULT/09_Athlete/10_トライアスロン/週間練習メニュー.md" ]]; then
    cp "$VAULT/09_Athlete/10_トライアスロン/週間練習メニュー.md" "$CONFIG_DIR/training-weekly-menu.md"
    echo "✓ 週間練習メニュー → $CONFIG_DIR/training-weekly-menu.md（トレリマインダー用）"
  fi
  if [[ -f "$VAULT/09_Athlete/70_食事/食事リマインド本文.md" ]]; then
    cp "$VAULT/09_Athlete/70_食事/食事リマインド本文.md" "$CONFIG_DIR/meal-reminder-bodies.md"
    echo "✓ 食事リマインド本文 → $CONFIG_DIR/meal-reminder-bodies.md"
  fi

  for TYPE in breakfast lunch snack dinner training work_end voice_journal bedtime; do
    local LABEL="com.lifeos.reminder-$TYPE"
    local PLIST_DEST="$PLIST_DIR/$LABEL.plist"
    cp "$SCRIPTS_SRC/com.lifeos.reminder-${TYPE}.plist.template" "$PLIST_DEST"
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    launchctl load -w "$PLIST_DEST"
    echo "✓ $LABEL 登録完了"
  done

  echo "✅ life-reminder 8件 登録完了"
  echo "   トレーニング時刻を変更する場合:"
  echo "   $PLIST_DIR/com.lifeos.reminder-training.plist を編集 → launchctl reload"
}

# ── デイリー自動 push（20:50 JST・GitHub バックアップ用・任意）────────
install_eod_push() {
  local LABEL="com.lifeos.eod-push"

  echo "──────────────────────────────────────────"
  echo " eod-push（デイリー自動 git push）"
  echo " 毎日 20:50 JST — 任意（Vault の GitHub バックアップ用）"
  echo "──────────────────────────────────────────"

  cp "$SCRIPTS_SRC/eod-push.sh" "$SCRIPTS_DEST/eod-push.sh"
  chmod +x "$SCRIPTS_DEST/eod-push.sh"
  echo "✓ スクリプト設置: $SCRIPTS_DEST/eod-push.sh"

  mkdir -p "$HOME/Library/Logs"

  local PLIST_DEST="$PLIST_DIR/$LABEL.plist"
  cat > "$PLIST_DEST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${SCRIPTS_DEST}/eod-push.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>20</integer>
        <key>Minute</key>
        <integer>50</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/${LABEL}.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/${LABEL}.err.log</string>

    <key>RunAtLoad</key>
    <false/>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin</string>
        <key>LANG</key>
        <string>ja_JP.UTF-8</string>
        <key>LIFEOS_VAULT</key>
        <string>${VAULT}</string>
    </dict>
</dict>
</plist>
EOF

  launchctl unload "$PLIST_DEST" 2>/dev/null || true
  launchctl load -w "$PLIST_DEST"
  echo "✅ ${LABEL} 登録完了（次回: 本日 or 翌 20:50 JST）"
  echo "   解除: launchctl unload -w $PLIST_DEST"
}

# ── 実行 ─────────────────────────────────────────────────
case "$TARGET" in
  p1-1)     install_p1_1 ;;
  reminder) install_reminder ;;
  eod-push) install_eod_push ;;
  all)
    install_p1_1
    echo ""
    install_reminder
    echo ""
    echo "══════════════════════════════════════════"
    echo "✅ 全ジョブ インストール完了"
    echo "══════════════════════════════════════════"
    echo ""
    echo "テスト配信:"
    echo "  bash $SCRIPTS_DEST/life-reminder.sh breakfast"
    echo ""
    echo "登録確認:"
    echo "  launchctl list | grep com.lifeos"
    echo ""
    echo "デイリーを GitHub に自動 push（任意）だけ入れる場合:"
    echo "  bash $0 eod-push"
    ;;
  *)
    echo "Usage: $0 [all|p1-1|reminder|eod-push]"
    exit 1
    ;;
esac
