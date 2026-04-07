#!/bin/bash
# new_company.sh — 企業フォルダ作成 + 応募台帳に1行追記
# 使い方: bash 50_自動化/scripts/new_company.sh <スラッグ> <企業名>
# 例:     bash 50_自動化/scripts/new_company.sh acme-corp "Acme株式会社"

set -e

SLUG="$1"
COMPANY_NAME="$2"

if [[ -z "$SLUG" || -z "$COMPANY_NAME" ]]; then
  echo "Usage: bash new_company.sh <slug> <company_name>"
  echo "Example: bash new_company.sh acme-corp \"Acme株式会社\""
  exit 1
fi

# スラッグにスペースや記号が含まれていないか確認
if [[ "$SLUG" =~ [[:space:]] ]]; then
  echo "ERROR: slug must not contain spaces. Use hyphens instead."
  exit 1
fi

# パス設定（スクリプトの場所から Vault ルートを計算）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CAMPAIGN="$VAULT_ROOT/03_Career/40_転職活動/10_campaigns/10_202604_career_transition"
TEMPLATE="$CAMPAIGN/companies/_template"
TARGET="$CAMPAIGN/companies/$SLUG"
APPLICATIONS="$CAMPAIGN/10_applications.md"

# テンプレート存在確認
if [[ ! -d "$TEMPLATE" ]]; then
  echo "ERROR: Template not found at $TEMPLATE"
  exit 1
fi

# 重複チェック
if [[ -d "$TARGET" ]]; then
  echo "ERROR: Company folder already exists: $TARGET"
  exit 1
fi

# テンプレートをコピー
cp -r "$TEMPLATE" "$TARGET"
rm -f "$TARGET/00_README.md"  # テンプレ説明ファイルは不要

# プレースホルダを置換
TODAY=$(date +%Y-%m-%d)
sed -i "" "s/（企業の正式名称）/$COMPANY_NAME/g" "$TARGET/10_company_info.md"
sed -i "" "s/（フォルダ名と同じ）/$SLUG/g" "$TARGET/10_company_info.md"
sed -i "" "s/YYYY-MM-DD/$TODAY/g" "$TARGET/10_company_info.md"

echo "✓ Created: companies/$SLUG/"

# 応募台帳に1行追加
ENTRY="| $TODAY | $COMPANY_NAME | $SLUG | 直応/紹介/スカウト |  | 応募準備 |  |  |"
echo "$ENTRY" >> "$APPLICATIONS"
echo "✓ Added to 10_applications.md"

echo ""
echo "次のステップ:"
echo "  1. /project:career/company-research $SLUG <JD_URL>"
echo "  2. 10_applications.md の経路・職種欄を埋める"
