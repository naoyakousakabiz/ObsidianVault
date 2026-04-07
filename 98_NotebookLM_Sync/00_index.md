---
date: 2026-04-08
type: index
domain: ai
status: active
source: claude-code
generated_at: 2026-04-08
reviewed: false
tags: []
---

# 98_NotebookLM_Sync — 概要・フォルダ対応表

## 役割

NotebookLM のソースとして同期されるファイル群。**直接編集しない**。  
Obsidian 側（本Vault）を編集 → GAS スクリプトで自動反映される（`99_System/01_NotebookLM_GAS_同期スクリプト.md` 参照）。

---

## 本Vaultとのフォルダ対応

| このフォルダ（98_NotebookLM_Sync/） | 本Vault の対応フォルダ | 内容 |
|---|---|---|
| `04_Asset/` | `07_Asset/` | 所有物管理・ファッション在庫・パーソナルプロフィール |
| `05_Athlete/` | `09_Athlete/` | アスリート管理（トライアスロン・筋トレ・食事・睡眠など） |

> **注意**: このフォルダの番号（`04_`, `05_`）は本Vaultの番号（`07_`, `09_`）と一致しない。  
> NotebookLM の「ノートブック番号」に合わせた採番のため、混同に注意。

---

## 同期ルール

- 編集は **本Vault側（`07_Asset/`, `09_Athlete/` 等）** で行う
- このフォルダ配下のファイルは GAS が上書きするため、手動変更は消える
- NotebookLM に追加したいソースが増えた場合は GAS スクリプトを更新する
