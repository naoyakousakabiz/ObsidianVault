#!/bin/bash
# weekly_pipeline.sh — 応募パイプラインを集計して表示
# 使い方: bash 50_自動化/scripts/weekly_pipeline.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
APPLICATIONS="$VAULT_ROOT/03_Career/40_転職活動/10_campaigns/10_202604_career_transition/10_applications.md"

if [[ ! -f "$APPLICATIONS" ]]; then
  echo "ERROR: applications file not found: $APPLICATIONS"
  exit 1
fi

echo "=== 応募パイプライン $(date '+%Y-%m-%d %H:%M') ==="
echo ""

# ステータス列（6列目）を集計
awk -F'|' '
NR > 3 && $6 !~ /ステータス/ && $6 !~ /^[-[:space:]]+$/ {
  status = $6
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
  if (status != "") counts[status]++
  total++
}
END {
  printf "合計: %d件\n\n", total
  # ステータス一覧
  for (s in counts) printf "  %-24s %2d件\n", s, counts[s]
}
' "$APPLICATIONS"

echo ""
echo "--- 直近5件の応募 ---"
awk -F'|' '
NR > 3 && $2 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
  date = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", date)
  company = $3; gsub(/^[[:space:]]+|[[:space:]]+$/, "", company)
  status = $6; gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
  printf "%s  %-20s  %s\n", date, company, status
}
' "$APPLICATIONS" | sort -r | head -5

echo ""
echo "--- 要アクション（次アクション欄が空でないもの）---"
awk -F'|' '
NR > 3 && $2 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
  company = $3; gsub(/^[[:space:]]+|[[:space:]]+$/, "", company)
  status = $6; gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
  next_action = $7; gsub(/^[[:space:]]+|[[:space:]]+$/, "", next_action)
  if (next_action != "" && next_action != "-") {
    printf "  %-20s [%s] → %s\n", company, status, next_action
  }
}
' "$APPLICATIONS"
