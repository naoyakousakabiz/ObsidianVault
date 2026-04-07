#!/usr/bin/env python3
"""
02_Voice 内の .m4a を、Pixel レコーダー由来の日本語名のままでも
Vault ルールどおり YYYY-MM-DD.m4a（同日複数は _001 付与）へリネームする。

日付はファイル名からは解析しない（誤年のリスクがあるため）。
macOS では st_birthtime（作成日時）、なければ st_mtime をローカル時刻で使用。

使い方:
  python3 99_System/scripts/rename_voice_m4a.py
  python3 99_System/scripts/rename_voice_m4a.py /path/to/80_Journal/02_Voice

定期実行例（launchd / cron）は 80_Journal/CLAUDE.md を参照。
"""
from __future__ import annotations

import re
import sys
from datetime import datetime
from pathlib import Path

ISO_NAME = re.compile(r"^(\d{4}-\d{2}-\d{2})(_\d{3})?\.m4a$", re.IGNORECASE)


def voice_dir(cli_arg: list[str]) -> Path:
    if len(cli_arg) >= 2:
        return Path(cli_arg[1]).expanduser().resolve()
    vault = Path(__file__).resolve().parent.parent.parent
    return vault / "80_Journal" / "02_Voice"


def file_date(p: Path) -> datetime:
    st = p.stat()
    ts = getattr(st, "st_birthtime", None)
    if ts is None or ts <= 0:
        ts = st.st_mtime
    return datetime.fromtimestamp(ts)


def next_name(root: Path, date_str: str, source: Path) -> Path:
    """空きの YYYY-MM-DD.m4a または YYYY-MM-DD_NNN.m4a を返す。"""
    base = root / f"{date_str}.m4a"
    if not base.exists() or base.resolve() == source.resolve():
        return base
    n = 1
    while True:
        alt = root / f"{date_str}_{n:03d}.m4a"
        if not alt.exists() or alt.resolve() == source.resolve():
            return alt
        n += 1


def main() -> int:
    root = voice_dir(sys.argv)
    if not root.is_dir():
        print(f"not a directory: {root}", file=sys.stderr)
        return 1

    count = 0
    for p in sorted(root.glob("*.m4a")):
        if not p.is_file():
            continue
        if ISO_NAME.match(p.name):
            continue
        d = file_date(p)
        date_str = d.strftime("%Y-%m-%d")
        dest = next_name(root, date_str, p)
        if dest.resolve() == p.resolve():
            continue
        p.rename(dest)
        print(f"{p.name} -> {dest.name}")
        count += 1

    if count == 0:
        print("no files to rename")
    return 0


if __name__ == "__main__":
    sys.exit(main())
