#!/usr/bin/env python3
"""Copy AI consulting templates from generic folder to RINGBELL 50_AI自動化 with path/YAML fixes."""

from __future__ import annotations

import re
from pathlib import Path

VAULT = Path(__file__).resolve().parents[2]
GENERIC = VAULT / "04_AI" / "02_AI導入コンサルテンプレートフォルダ"
RINGBELL = VAULT / "02_Business" / "RINGBELL" / "50_AI自動化"

PREFIX = "04_AI/02_AI導入コンサルテンプレートフォルダ"
ROADMAP = "01_AI導入ロードマップ.md"
FOLDER_DESIGN = "02_フォルダ設計.md"
EXEC_GENERIC = f"{PREFIX}/03_Executiveセルフチェックリスト.md"

REL_SYNC = [
    "01_AI導入ロードマップ.md",
    "02_フォルダ設計.md",
    "10_業務整理/00_README.md",
    "10_業務整理/テンプレ_AI適用・人的判断の分界.md",
    "10_業務整理/テンプレ_スコープと関係者.md",
    "10_業務整理/テンプレ_ヒアリング項目一覧.md",
    "10_業務整理/テンプレ_現状と課題.md",
    "10_業務整理/ヒアリングシート_1.0.md",
    "20_設計/00_README.md",
    "20_設計/テンプレ_To-Beとシステム境界.md",
    "30_実行計画/00_README.md",
    "30_実行計画/テンプレ_実行計画サマリー.md",
    "30_実行計画/テンプレ_リスクと外部サービス.md",
    "30_実行計画/テンプレ_定着メモ.md",
    "30_実行計画/テンプレ_クライアント向け1枚サマリー.md",
    "40_施策実装/00_README.md",
    "40_施策実装/00_施策一覧.md",
    "40_施策実装/テンプレ_施策設計書.md",
    "50_資産化/00_README.md",
    "50_資産化/テンプレ_学びと事例.md",
    "99_アーカイブ/00_README.md",
]


def _domain_business(text: str) -> str:
    return re.sub(r"^domain: ai$", "domain: business", text, flags=re.MULTILINE)


def _ensure_ringbell_tag(text: str) -> str:
    def _tags(line: str) -> str:
        if not line.startswith("tags:"):
            return line
        if "RINGBELL" in line:
            return line
        if line.strip() == "tags: []":
            return "tags: [RINGBELL]"
        return line.replace("tags: [", "tags: [RINGBELL, ", 1)

    return "\n".join(_tags(L) if L.startswith("tags:") else L for L in text.splitlines()) + (
        "\n" if text.endswith("\n") else ""
    )


def _paths(text: str) -> str:
    # Keep links local within the RINGBELL copy.
    # (Generic master paths are referenced explicitly in the RINGBELL wrapper docs.)
    text = text.replace("../01_AI導入ロードマップ.md", f"../{ROADMAP}")
    text = text.replace("../02_フォルダ設計.md", f"../{FOLDER_DESIGN}")
    text = text.replace("../03_Executiveセルフチェックリスト.md", "../03_Executiveセルフチェックリスト.md")
    return text


def _sync_file(rel: str) -> None:
    src = GENERIC / rel
    dst = RINGBELL / rel
    if not src.is_file():
        raise SystemExit(f"missing source: {src}")
    raw = src.read_text(encoding="utf-8")
    out = _ensure_ringbell_tag(_domain_business(raw))
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(out, encoding="utf-8")
    print(f"OK {rel}")


def _write_executive_ringbell() -> None:
    src = GENERIC / "03_Executiveセルフチェックリスト.md"
    dst = RINGBELL / "03_Executiveセルフチェックリスト.md"
    body = src.read_text(encoding="utf-8")
    body = _domain_business(body)
    body = body.replace(
        "tags: [AI導入, 品質, チェックリスト, 汎用]",
        "tags: [RINGBELL, AI自動化, 品質, チェックリスト, コンサル]",
    )
    body = body.replace(
        "# AI導入コンサル — Executive セルフチェックリスト（コンパクト版）",
        "# AI活用・業務自動化 — Executive セルフチェックリスト（コンパクト版・作業コピー）",
    )
    old_intro = (
        "> **用途:** 個人事業〜中小規模でも**プロ納品として外されない最低ライン**を1枚で確認する。  \n"
        "> **手順・進捗（状態列）の正:** `01_AI導入ロードマップ.md`  \n"
        "> **テンプレの一覧・原則・冗長排除ルールの正:** `02_フォルダ設計.md`\n"
        "> **本ファイルの正:** チェック表と下の「項目→テンプレ」対応のみ（テンプレのパス一覧は書き足さない）  \n"
        "> **レベル感:** 大手ファームのパートナー向けアタッチメントほどの厚みは意図的に別紙だが、**説明責任・責任あるAI・経済性・運用**まで一巡する**パートナーが嫌がる抜け穴を塞ぐ**ための18項＋最終3問。"
    )
    new_intro = (
        "> **用途:** RINGBELL 副業オペでも**プロ納品として外されない最低ライン**を1枚で確認する。  \n"
        f"> **汎用版の正本:** `{EXEC_GENERIC}`（改善時は先にそちらを更新し、必要なら本ファイルへ反映）  \n"
        f"> **手順・進捗（状態列）の正:** `{ROADMAP}`  \n"
        f"> **テンプレの一覧・原則・冗長排除ルールの正:** `{FOLDER_DESIGN}`  \n"
        "> **本ファイル（作業コピー）の正:** チェック表と下の「項目→テンプレ」対応のみ（テンプレのパス一覧は書き足さない）  \n"
        "> **レベル感:** 大手ファームのパートナー向けアタッチメントほどの厚みは意図的に別紙だが、**説明責任・責任あるAI・経済性・運用**まで一巡する**パートナーが嫌がる抜け穴を塞ぐ**ための18項＋最終3問。"
    )
    if old_intro not in body:
        raise SystemExit("generic Executive intro block changed; update sync script")
    body = body.replace(old_intro, new_intro, 1)
    dst.write_text(body, encoding="utf-8")
    print("OK 03_Executiveセルフチェックリスト.md (from 03_)")


def _write_background_ringbell() -> None:
    src = GENERIC / "00_背景と設計意図.md"
    text = src.read_text(encoding="utf-8")
    text = _domain_business(text)
    text = text.replace(
        "tags: [AI導入, コンサル, メタ, 設計思想]",
        "tags: [RINGBELL, AI自動化, メタ, 設計思想]",
    )
    text = text.replace(
        "# AI導入コンサルテンプレートフォルダ — 背景・意図・前提",
        "# RINGBELL `50_AI自動化/` — 背景・意図・前提（作業コピー）",
    )
    text = text.replace(
        "**作業コピーの例:** `02_Business/RINGBELL/50_AI自動化/` — 棚構造は揃えつつ、**型の正本は本フォルダ**、RINGBELL 固有の長文・施策実体は案件側。",
        "**本作業棚:** いま開いている `50_AI自動化/`。**このフォルダ直下の索引・テンプレ一覧の入口**は `02_フォルダ設計.md`。**型の正本（汎用）**は `04_AI/02_AI導入コンサルテンプレートフォルダ/`。",
    )
    text = text.replace(
        "**「何を・なぜこの形で残すか」のメタ説明**である。手順の実行自体は `01_AI導入ロードマップ.md`、ファイル名の一覧と単一正本ルールは `02_フォルダ設計.md`、納品直前の網羅確認は `03_Executiveセルフチェックリスト.md` を正とする。",
        "**「何を・なぜこの形で残すか」のメタ説明（作業コピー側）**である。手順の実行自体は汎用の "
        f"`{ROADMAP}`、ファイル名の一覧と単一正本ルールは汎用の `{FOLDER_DESIGN}`、納品直前の網羅確認は本作業棚の "
        "`03_Executiveセルフチェックリスト.md`（中身は汎用 `03_Executive…` と同期）を正とする。",
    )
    out_path = RINGBELL / "00_背景と設計意図.md"
    out_path.write_text(text, encoding="utf-8")
    print(f"OK {out_path.relative_to(VAULT)}")


def main() -> None:
    if not GENERIC.is_dir() or not RINGBELL.is_dir():
        raise SystemExit("generic or ringbell folder missing")
    for rel in REL_SYNC:
        _sync_file(rel)
    _write_executive_ringbell()
    _write_background_ringbell()


if __name__ == "__main__":
    main()
