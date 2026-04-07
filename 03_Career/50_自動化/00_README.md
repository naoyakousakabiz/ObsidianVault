# 50_自動化 — 自動化設計

転職活動の繰り返し作業を Claude Code スラッシュコマンドとスクリプトで自動化する。

## ワークフロー一覧

| # | ワークフロー | コマンド | タイミング |
|---|-------------|----------|-----------|
| 1 | 企業調査生成 | `/project:career/company-research <スラッグ> <URL>` | 応募時 |
| 2 | 面談振り返り | `/project:career/interview-review <スラッグ>` | 面接後すぐ |
| 3 | 想定Q&A生成 | `/project:career/qa-gen <スラッグ> [1次/2次/役員]` | 面接前日 |
| 4 | 書類カスタム | `/project:career/doc-custom <スラッグ> [both/resume/work_history]` | 書類提出前 |
| 5 | キャリア情勢 | `/project:career/career-catchup` | 週1（月曜朝） |

## スクリプト一覧

| スクリプト | 用途 | 使い方 |
|-----------|------|--------|
| `scripts/new_company.sh` | 企業フォルダ作成 + 台帳追記 | `bash 50_自動化/scripts/new_company.sh <スラッグ> <企業名>` |
| `scripts/weekly_pipeline.sh` | 応募状況の集計 | `bash 50_自動化/scripts/weekly_pipeline.sh` |

## 典型的な1週間の流れ

```
月曜朝:
  /project:career/career-catchup
  → synthesis/ に市場メモ追記、戦略仮説の更新を確認

応募発生時:
  bash 50_自動化/scripts/new_company.sh acme-corp "Acme株式会社"
  /project:career/company-research acme-corp https://acme.co.jp/jobs/123
  → companies/acme-corp/ が作成され、10_company_info.md が埋まる

面接前日:
  /project:career/qa-gen acme-corp 1次
  → 10_qa.md の想定Q&A 埋め、30_prep_common.md で汎用トーク見直し

面接後すぐ（メモをチャットに貼り付けて）:
  /project:career/interview-review acme-corp 1次
  → ログ構造化 + 改善点抽出 → 10_company_info.md / 10_qa.md に反映

書類提出前:
  /project:career/doc-custom acme-corp
  → companies/acme-corp/derived_work_history.md が生成される

週末:
  bash 50_自動化/scripts/weekly_pipeline.sh
  → ファネル確認 → 00_pipeline.md 手動更新
```

## ファイルパス（各コマンド内で参照）

| 役割 | パス |
|------|------|
| 正本（事実・数値） | `03_Career/10_プロフィール/` |
| 汎用提出書類 | `03_Career/20_マスタ/` |
| 戦略・方針 | `03_Career/30_キャリア戦略/` |
| キャンペーン | `03_Career/40_転職活動/10_campaigns/10_202604_career_transition/` |
| 企業フォルダ | `…/companies/<スラッグ>/` |

## スラッシュコマンドの実体

`.claude/commands/career/` に置いている（Vault ルートの `.claude/` 配下）。

## 優先実装順（着手推奨）

1. `company-research` → 毎応募で使う、効果が即出る
2. `interview-review` → 面接後すぐ使う、改善ループが回る
3. `qa-gen` → 面接前の準備時間を大幅削減
4. `career-catchup` → 週1スケジュールで積み上げ
5. `doc-custom` → 書類選考数が増えてから
