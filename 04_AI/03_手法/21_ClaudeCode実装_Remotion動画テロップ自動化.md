---
date: 2026-04-12
type: playbook
domain: ai
status: active
source: human
tags: [ClaudeCode, Remotion, 動画, リップシンク, Whisper, HiggsField, Kling]
---

# Claude Code × Remotion 動画量産フロー（リップシンク → テロップ自動）

**概要:** 1枚の画像からリップシンク動画を作り（HiggsField / Kling 系）、**Claude Code + Remotion +（任意）Whisper** でテロップ・タイミングを自動化する流れのメモ。

**出典:** X **月島くん**（`@wancoro_xx`）2026-04-11 頃の解説を要約・再構成。**各サービスの利用規約・商用可否・肖像権は利用前に確認。** API キーは Vault に書かない。

---

## 必要なもの（チェックリスト）

| 種別 | 内容 |
| --- | --- |
| 動画生成 | **HiggsField**（または **Kling** 等）API／アカウント |
| 編集自動化 | **Claude Code** |
| Remotion スキル | `npx skills add remotion-dev/skills`（パッケージ名は導入時に公式を確認） |
| タイミング精度（任意だが推奨） | **OpenAI API**（Whisper `whisper-1`、word タイムスタンプ用） |

---

## 1. 喋る動画の生成（リップシンク）

1. **画像:** 正面・**口がはっきり見える**素材（実写・イラスト可）。認識されにくいとリップが崩れやすい。
2. **HiggsField:** image → Nanobanana Pro 等で元画作成 → **Video → Lipsync Studio → Model（例: Kling Avatar 2.0）**。
3. **音声:** テキスト読み上げ or 音声ファイルアップロード（例: Fish Audio 等で生成した WAV）。**長さ上限（例: 最大約5分）はサービス仕様に従う。**
4. **動画用プロンプト例（投稿より要約）:** 口パク・高齢寄りのリズム・間・頷き・表情などを英日で指定。
5. **書き出し:** 解像度（1080p / 720p でクレジット差）に注意。**ファイル名は分かりやすく保存**（例: `月島動画01.mp4`）。
6. **仕上げ（手動でも可）:** CapCut 等でテロップのみ足して完結させることも可能。

---

## 2. Claude Code で Remotion を使えるようにする

```bash
npx skills add remotion-dev/skills
```

- 対話で止まったら指示に従い **Yes** で進める。再起動を求められたら **Claude Code を再起動**。
- 記事上の表記揺れ（「Rmotion」等）は **Remotion** と読み替え。

既存 Vault スキルとの関係: `.claude/skills/remotion-video` は **ずんだもん解説動画**向けの別レーン。本フローは **既存 MP4 + Whisper + テロップ合成** 寄り。

---

## 3. OpenAI API（Whisper）— 任意だが精度用

- **目的:** 台本テキストだけでは「動画の何秒でその語が喋られているか」が Remotion 側で分からない。**Whisper の word レベルタイムスタンプ**でテロップ同期を自動化する。
- **手順の要約:** [OpenAI Platform](https://platform.openai.com/) でログイン → 課金・クレジット設定 → API keys で `sk-...` を発行（**表示は一度きり** → 秘密管理ツールへ）。
- **コスト感:** 記事では Whisper が **おおよそ 1 分あたり 1 円未満**のイメージで、少額チャージで多数本処理可能、とある。**実額は OpenAI 公式の料金表で要確認**。

---

## 4. Claude Code に渡す Remotion 一括プロンプト（コピー用）

以下を **そのまま Claude Code に貼り付け**。動画パス・`.env` の `OPENAI_API_KEY`・台本を都度指定する。

```text
あなたは超優秀なフルスタックエンジニアであり、
Remotionを用いた動画テロップ実装のスペシャリストです。
以下を最初から最後まで自動で実行してください。
途中でユーザーの入力を待つ場合以外は止まらずに完了させること。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【絶対厳守のUI/UX仕様】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. 動画の上にはテロップのみ。説明パネル・サイドバー等の
   装飾コンポーネントは一切実装・表示しないこと。

2. テロップは「絶対に1行」。
   - whiteSpace: "nowrap" で折り返し禁止を強制すること。
   - テキスト幅を文字種別（全角≒fontSize×0.92、
     半角≒fontSize×0.55）で推定し、
     動画幅の94%に収まるようfontSizeを自動スケールダウンする
     関数 calcFontSize(text, videoWidth) を必ず実装すること。
   - 基準フォントサイズは68px、最小は34px。

3. テロップ位置は「paddingBottom = height * 0.08」で
   画面下部8%に固定。

4. デザイン仕様：
   - 白文字 (#FFFFFF)、フォント: Noto Sans JP weight:900
   - 白文字の縁取り：「8方向 5px text-shadow」赤 (#FF0000)。
     実装: [-5, 0, 5] × [-5, 0, 5] の組み合わせ
     （0,0を除く8方向）それぞれ `Xpx Ypx 0 #FF0000`
   - 重要キーワードは color: "#FFFF00" でハイライト。
     キーワードの縁取り：「8方向 5px text-shadow」黒 (#000000)。
     キーワードは長いものから順にマッチさせ二重タグを防ぐこと。

5. テロップ出現アニメーション：
   spring(damping:20, stiffness:160, mass:0.65) で
   translateY 28→0px かつ opacity 0→1 のフェードイン。
   durationInFrames: Math.round(fps * 0.28)
   ※ ただし startFrame === 0 の最初のテロップのみ
     アニメーションをスキップし、opacity=1・translateY=0 で即表示。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【手順1】動画の配置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PC内（Downloadsフォルダ等）から対象動画を検索し、
Remotionプロジェクトの public/video.mp4 に配置すること。
既存のRemotionプロジェクトがあれば再利用する。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【手順2】ユーザー入力
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
以下を確認・取得すること：
A) OpenAI APIキー → .env の OPENAI_API_KEY に保存
B) 台本テキスト（改行区切り） →
   「改行1行 = テロップ1枚」として扱う

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【手順3】音声抽出 → Whisper word-level 取得
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. ffmpegで video.mp4 から audio.wav を抽出。
2. Whisper API (whisper-1) を以下パラメータで呼び出す
   Node.jsスクリプト scripts/transcribe_words.mjs を作成・実行：
   - response_format: "verbose_json"
   - timestamp_granularities[]: "word"
   - language: "ja"
   - prompt: 台本テキスト（表記揺れ防止）
   結果を scripts/whisper_words_raw.json に保存。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【手順4】台本ベースのタイムスタンプアライメント
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
scripts/script_align.mjs を作成・実行：

アルゴリズム（必ずこの方式で実装）：
1. Whisper の words[] から句読点・記号を除去した
   「正規化文字ストリーム」を構築し、
   各文字に対してその単語の秒数を線形補間で割り当てる。
2. 台本全行を連結した正規化文字列の長さを基準に、
   各行の先頭文字位置を Whisper ストリームに比例マッピング：
   whisperIdx = round(scriptCharPos / totalScriptNormLen
                       * totalWhisperNormLen)
3. 各行の startTime = マップ先の whisper 文字の秒数、
   endTime = 次行の startTime（最終行のみ
   words[lastIdx].end を使用して無音末尾をカット）。
4. キーワードに <b>タグ</b> を付けて src/data/captions.ts に出力。
   型は @remotion/captions の Caption[]。
   各オブジェクトに timestampMs: startMs, confidence: 1 も必須。

正規化関数の除去対象：
句読点全般 (。、！？・…×「」『』【】（）,.!?) + 空白・記号

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【手順5】Remotionコンポーネント実装
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
src/components/Subtitle.tsx：
- 上記【絶対厳守のUI/UX仕様】を完全に満たすこと。
- useVideoConfig() から width / height / fps を取得し、
  全てのサイズ計算に使用すること。
- SubtitlePage は animate: boolean プロップを受け取り、
  false のときは即表示（opacity=1, translateY=0）。
- SubtitleLayer では startFrame === 0 のとき animate={false} を渡す。

src/[VideoName].tsx：
- <Video src={staticFile("video.mp4")} /> と
  <SubtitleLayer> のみで構成。装飾コンポーネント不可。

src/Root.tsx の calculateMetadata：
- mediabunny で動画の実サイズ・fps を取得。
- CAPTIONS をインポートし、
  durationInFrames = Math.ceil(
    Math.min(videoDuration, lastCaption.endMs/1000 + 0.05) * fps
  ) で、最終セリフ終了時に動画を終了させること。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【手順6】完了
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
npx tsc --noEmit でエラーがないことを確認してから
npm start でプレビューを起動し、完了を報告すること。
```

### プロンプト変更メモ（投稿の「主な変更点」）

- フォントサイズ基準 54px → **68px**
- 白文字フチ: 黒 2.5px → **赤 #FF0000 5px**
- キーワード色: #FFD700 → **#FFFF00**
- キーワードフチ: **黒 #000000 5px**
- Caption に **timestampMs** と **confidence: 1** を必須化
- **startFrame === 0** のテロップはアニメーションスキップ

---

## 5. その後の拡張

同じ Remotion プロジェクト上で、チャット指示により **エフェクト・スライド・BGM** 等を足す、という伸ばし方が可能（記事主張）。

---

## リスク・ガバナンス

- **スクレイピング・生成物の著作権・肖像・商用利用**は各ツールの ToS と `.claude/skills/00_shared-governance.md` に沿う。
- **API キー**は `.env`（git 外）と秘密管理ツールのみ。プロンプトや CLAUDE.md に貼らない。
- 生成モデル・API の**価格・上限**は変更が速い。都度公式を確認。

---

## 関連

- Vault スキル: `.claude/skills/remotion-video.md`（解説動画レーン）
- 縦動画: `.claude/skills/edit-vertical-video.md`
- セキュリティ: [[04_AI/04_学習/ClaudeCode_初期設定手順まとめ]] Step 5
