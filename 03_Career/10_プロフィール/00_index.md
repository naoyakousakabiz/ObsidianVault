---
date: 2026-04-07
type: index
domain: career
status: active
source: human
tags: [profile, career]
---

# 10_プロフィール — 事実正本

**読む・直す目安順:** `00`（このファイル）→ **`10_resume.md`**（履歴書の素）→ **`20_work_history.md`**（職務経歴・実績）→ **`30_traits.md`**（強み・性格・志向）

| ファイル | 役割 | 下流 |
|----------|------|------|
| `10_resume.md` | 学歴・職歴（短文）・資格・基本情報 | `20_マスタ/10_resume.md` |
| `20_work_history.md` | 職歴詳細・案件・KPI・定量 | `20_マスタ/20_work_history.md` |
| `30_traits.md` | 強み・弱み・性格/スタイル・志向・面接の素 | 面接・自己PR |

**流れ:** 正本を更新 → `20_マスタ/` で提出文 → 企業別は `40_転職活動/.../companies/`（転職オペの地図は `40_転職活動/00_index.md`）。戦略に採用する結論だけ `30_キャリア戦略/20_planning.md` へ。市場一般論の束ねは `30_キャリア戦略/synthesis/`（戦略フォルダの地図は `30_キャリア戦略/00_index.md`）。

## OK / NG

| OK | NG |
|----|-----|
| 日付・役割つきの実績、Before/After、証拠つきの強み | 採用に直出しする完成文（→ `20_マスタ/`） |
| 観測できた事実・自分の行動 | 市場一般論だけ（→ `synthesis/`） |

## NotebookLM 投入前

- [ ] 日付・役割が具体（特に `20_work_history.md`）
- [ ] 各案件に定量が1つ以上
- [ ] KPI に定義・Before/After・期間
- [ ] 強みは `20_work_history.md` へ紐付け・弱みに対策（`30_traits.md`）
- [ ] `10_resume` と `20_work_history` の社名・期間が矛盾していない
- [ ] 機密は匿名化
