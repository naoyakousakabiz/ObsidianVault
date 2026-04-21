#!/usr/bin/env bash
# append-shell-history-to-daily.sh — 当日デイリーの「ターミナル」欄を更新（ローカルのみ）
#
# やること:
#   - zsh の履歴ファイルの末尾を読み、<!-- AUTO_SHELL_START --> ～ END の間を置き換える
#   - マーカーが無いデイリーには、末尾に「作業詳細ログ」セクションごと追加する
#
# 注意: 履歴にパスワード・トークンが含まれる可能性がある。Git に push する前に目視確認すること。
#
# 使い方:
#   cd /path/to/ObsibianVault
#   bash 05_Life/50_AI自動化/scripts/append-shell-history-to-daily.sh
#
# 環境変数:
#   HIST_LINES — 取り込む行数（既定 50）
#   LIFEOS_VAULT / VAULT — Vault ルート
#   JOURNAL_DATE — 対象日 YYYY-MM-DD（省略時は東京の今日。テスト用）

set -euo pipefail

LINES="${HIST_LINES:-50}"
ROOT="${LIFEOS_VAULT:-${VAULT:-}}"
if [[ -n "$ROOT" ]]; then
  cd "$ROOT"
else
  cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || {
    echo "append-shell-history: cannot cd to vault; set LIFEOS_VAULT" >&2
    exit 1
  }
fi

TODAY="${JOURNAL_DATE:-$(TZ=Asia/Tokyo date +%Y-%m-%d)}"
DAILY="80_Journal/01_Daily/${TODAY}.md"

if [[ ! -f "$DAILY" ]]; then
  echo "daily not found: $DAILY" >&2
  exit 1
fi

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
if [[ ! -r "$HISTFILE" ]]; then
  echo "cannot read HISTFILE: $HISTFILE" >&2
  exit 1
fi

export DAILY_PATH="$DAILY"
export HISTFILE_PATH="$HISTFILE"
export HIST_LINES_LIM="$LINES"

python3 - <<'PY'
import os
import re
from pathlib import Path

hist_path = Path(os.environ["HISTFILE_PATH"])
raw_lines = hist_path.read_bytes().decode("utf-8", errors="replace").splitlines()
n = int(os.environ["HIST_LINES_LIM"])
chunk = raw_lines[-n:] if len(raw_lines) >= n else raw_lines
stripped = []
for line in chunk:
    stripped.append(re.sub(r"^:[0-9]+:[0-9]+;", "", line))
hist = "\n".join(stripped).rstrip("\n")

path = Path(os.environ["DAILY_PATH"])
text = path.read_text(encoding="utf-8")

fence = "```text\n" + hist + "\n```"

inner = f"""**この欄は何ですか？**
ターミナル（Mac の「ターミナル」アプリや Cursor のターミナル）で、あなたが打ったコマンドの **直近の一部** です。

**やさしい説明**
- 1行が1回の入力のイメージです（順序は環境によって前後することがあります）。
- `git` や `cd` など、よく出てくる言葉があれば「その日触った作業の手がかり」になります。
- よく分からない行は **飛ばして大丈夫** です。

**注意（必読）**
パスワード・APIキー・トークンが混ざることがあります。**Git に push する前に必ず目視で確認**し、必要ならこの欄を削ってください。

{fence}
"""

start = "<!-- AUTO_SHELL_START -->"
end = "<!-- AUTO_SHELL_END -->"
block = f"{start}\n{inner}\n{end}"

if start in text and end in text:
    text = re.sub(
        re.escape(start) + r".*?" + re.escape(end),
        block,
        text,
        count=1,
        flags=re.DOTALL,
    )
else:
    tail = f"""

---

## 作業詳細ログ（任意）

ここは **1日の補足記録** 用です（Obsidian 上のメモ）。

### ターミナル（zsh）で打ったコマンド

{block}

### Cursor（エディタ）でのやり取り

- **自動では入りません。** 決めたこと・調べたことを箇条書きで残してください。

- 
"""
    text = text.rstrip() + tail

path.write_text(text, encoding="utf-8")
PY

echo "updated: $DAILY (ターミナル欄)"
