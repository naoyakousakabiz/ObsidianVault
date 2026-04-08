#!/usr/bin/env python3
"""
Vault 直下から再帰的にディレクトリツリーを書き出す。
.git のみ除外。出力先デフォルトは 99_System/vault_directory_tree_full.txt

使い方（Vault ルートで）:
  python3 99_System/scripts/export_vault_tree.py
  python3 99_System/scripts/export_vault_tree.py -o path/to/out.txt
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path

SKIP_NAMES = {".git"}


def walk(root: Path, prefix: str, lines: list[str]) -> None:
    try:
        names = sorted(
            [p.name for p in root.iterdir() if p.name not in SKIP_NAMES],
            key=lambda x: (x.lower(), x),
        )
    except PermissionError:
        return
    dirs = [n for n in names if (root / n).is_dir()]
    files = [n for n in names if not (root / n).is_dir()]
    entries = [(True, d) for d in dirs] + [(False, f) for f in files]
    for i, (is_dir, name) in enumerate(entries):
        last = i == len(entries) - 1
        branch = "└── " if last else "├── "
        lines.append(prefix + branch + name + ("/" if is_dir else ""))
        if is_dir:
            ext = "    " if last else "│   "
            walk(root / name, prefix + ext, lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Export Obsidian vault directory tree.")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output file (default: <vault>/99_System/vault_directory_tree_full.txt)",
    )
    args = parser.parse_args()

    script = Path(__file__).resolve()
    vault_root = script.parents[2]
    out = args.output
    if out is None:
        out = vault_root / "99_System" / "vault_directory_tree_full.txt"
    out = out.resolve()

    lines: list[str] = ["./"]
    walk(vault_root, "", lines)
    text = "\n".join(lines) + "\n"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")
    print(f"Wrote {len(lines)} lines to {out}")


if __name__ == "__main__":
    main()
