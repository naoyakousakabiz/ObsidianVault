#!/usr/bin/env python3
"""
縦型動画編集パイプライン v2（TikTok / Shorts / Reels向け）

機能:
  - 自動クロップ（横動画→縦9:16）
  - 明るさ・コントラスト自動補正（SNS映え）
  - 無音カット
  - Whisper文字起こし（通常 or カラオケ風ワードハイライト）
  - Claude API字幕セルフチェック・修正
  - 字幕折り返し（20文字/行）
  - 冒頭タイトルテキスト
  - フェードイン/アウト
  - BGM自動DL（ジャンル選択）＆合成（末尾フェードアウト付き）
  - プラットフォーム別プリセット（tiktok/reels/shorts）
  - サムネイル自動生成
  - バッチ処理（ディレクトリ指定）

使い方:
  python3 vertical_video_pipeline.py clip.mp4 --preset tiktok --download-bgm
  python3 vertical_video_pipeline.py ./videos/ --preset reels --bgm-genre lofi
  python3 vertical_video_pipeline.py clip.mp4 --title "AIで変わる仕事術" --karaoke

依存:
  brew install homebrew-ffmpeg/ffmpeg/ffmpeg  (libass必須)
  pip3 install faster-whisper anthropic yt-dlp
"""

import argparse
import os
import re
import shutil
import subprocess
import textwrap
import tempfile
from pathlib import Path

DOWNLOADS = Path.home() / "Downloads"
BGM_DIR = DOWNLOADS / "_bgm_cache"

# ── 字幕設定（ここだけ変えれば全体に反映）──────────
SUBTITLE_FONT_SIZE = 66    # フォントサイズ(px)  ※元の22pxの3倍
SUBTITLE_MAX_CHARS = 13    # 1行最大文字数（フォントサイズに連動して調整）
SUBTITLE_MARGIN_V  = 60    # 画面下端からのマージン(px)

PRESETS = {
    "tiktok":  {"width": 1080, "height": 1920, "fps": 30, "max_duration": 60},
    "reels":   {"width": 1080, "height": 1920, "fps": 30, "max_duration": 90},
    "shorts":  {"width": 1080, "height": 1920, "fps": 60, "max_duration": 60},
    "default": {"width": 1080, "height": 1920, "fps": 30, "max_duration": None},
}

BGM_SEARCH = {
    "pop":       "pop upbeat background music no copyright free",
    "lofi":      "lofi hip hop chill background music no copyright",
    "energetic": "energetic upbeat background music no copyright free",
}

TIKTOK_STYLE = (
    "FontName=Hiragino Sans,"
    "FontSize=52,"
    "PrimaryColour=&H00FFFFFF,"
    "OutlineColour=&H00000000,"
    "Outline=2,Shadow=1,Bold=1,"
    "BorderStyle=1,Alignment=2,MarginV=60"
)


# ─────────────────────────────────────────────
# Utils
# ─────────────────────────────────────────────

def get_video_info(path: Path) -> dict:
    result = subprocess.run([
        "ffprobe", "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "stream=width,height,r_frame_rate",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1",
        str(path)
    ], capture_output=True, text=True, check=True)
    info = {}
    for line in result.stdout.split("\n"):
        if "=" in line:
            k, v = line.split("=", 1)
            info[k.strip()] = v.strip()
    w = int(info.get("width", 0))
    h = int(info.get("height", 0))
    dur = float(info.get("duration", 0))
    fps_str = info.get("r_frame_rate", "30/1")
    num, den = fps_str.split("/")
    fps = float(num) / float(den)
    return {"width": w, "height": h, "duration": dur, "fps": fps}


def fmt_srt(s: float) -> str:
    h, s = divmod(s, 3600)
    m, s = divmod(s, 60)
    return f"{int(h):02d}:{int(m):02d}:{int(s):02d},{int(s % 1 * 1000):03d}"


def fmt_ass(s: float) -> str:
    h, s = divmod(s, 3600)
    m, s = divmod(s, 60)
    return f"{int(h)}:{int(m):02d}:{s:05.2f}"


def wrap_srt_file(srt_file: Path, max_chars: int = SUBTITLE_MAX_CHARS):
    """字幕テキストをフォントサイズに合わせた文字数で折り返す（最大2行）"""
    content = srt_file.read_text(encoding="utf-8")
    blocks = content.strip().split("\n\n")
    out = []
    for block in blocks:
        lines = block.split("\n")
        if len(lines) >= 3:
            text = "".join(lines[2:]).replace("\n", "")
            wrapped_lines = textwrap.wrap(text, max_chars, break_long_words=True)
            wrapped = "\n".join(wrapped_lines[:2])  # 最大2行
            out.append("\n".join(lines[:2]) + "\n" + wrapped)
        else:
            out.append(block)
    srt_file.write_text("\n\n".join(out) + "\n", encoding="utf-8")


# ─────────────────────────────────────────────
# Step 1: 前処理（クロップ・リサイズ・補正・fps）
# ─────────────────────────────────────────────

def preprocess(input_file: Path, output_file: Path, preset: dict, enhance: bool):
    print("[1/8] 前処理中（クロップ・リサイズ・補正）...")
    info = get_video_info(input_file)
    w, h = info["width"], info["height"]
    tw, th, tfps = preset["width"], preset["height"], preset["fps"]

    filters = []

    # 横→縦クロップ
    if w > h:
        crop_w = int(h * 9 / 16)
        crop_x = (w - crop_w) // 2
        filters.append(f"crop={crop_w}:{h}:{crop_x}:0")
        print(f"  横→縦クロップ: {w}x{h} → {crop_w}x{h}")

    # リサイズ（アスペクト比維持・レターボックス）
    filters.append(f"scale={tw}:{th}:force_original_aspect_ratio=decrease")
    filters.append(f"pad={tw}:{th}:(ow-iw)/2:(oh-ih)/2:black")

    # fps
    filters.append(f"fps={tfps}")

    # 明るさ・コントラスト補正（SNS映え）
    if enhance:
        filters.append("unsharp=5:5:0.6:3:3:0.0")
        filters.append("eq=contrast=1.08:brightness=0.04:saturation=1.12")

    subprocess.run([
        "ffmpeg", "-i", str(input_file),
        "-vf", ",".join(filters),
        "-c:a", "aac", "-b:a", "128k",
        "-y", str(output_file)
    ], check=True, capture_output=True)
    print(f"  → {output_file.name}")


# ─────────────────────────────────────────────
# Step 2: 無音カット
# ─────────────────────────────────────────────

def cut_silence(input_file: Path, output_file: Path, noise_db: float, min_sec: float):
    print("[2/8] 無音カット中...")
    info = get_video_info(input_file)
    result = subprocess.run(
        ["ffmpeg", "-i", str(input_file),
         "-af", f"silencedetect=noise={noise_db}dB:d={min_sec}", "-f", "null", "-"],
        capture_output=True, text=True
    )
    starts, ends = [], []
    for line in result.stderr.split("\n"):
        m = re.search(r"silence_start: ([\d.]+)", line)
        if m: starts.append(float(m.group(1)))
        m = re.search(r"silence_end: ([\d.]+)", line)
        if m: ends.append(float(m.group(1)))
    segs = list(zip(starts, ends))

    if not segs:
        print("  無音区間なし → そのままコピー")
        shutil.copy(str(input_file), str(output_file))
        return

    keep, prev = [], 0.0
    for s, e in segs:
        if s > prev + 0.05: keep.append((prev, s))
        prev = e
    if prev < info["duration"] - 0.05: keep.append((prev, info["duration"]))

    print(f"  無音 {len(segs)}箇所カット → {len(keep)}セグメント保持")
    expr = "+".join(f"between(t,{s},{e})" for s, e in keep)
    subprocess.run([
        "ffmpeg", "-i", str(input_file),
        "-vf", f"select='{expr}',setpts=N/FRAME_RATE/TB",
        "-af", f"aselect='{expr}',asetpts=N/SR/TB",
        "-y", str(output_file)
    ], check=True, capture_output=True)
    print(f"  → {output_file.name}")


# ─────────────────────────────────────────────
# Step 3: Whisper文字起こし
# ─────────────────────────────────────────────

def transcribe(input_file: Path, srt_file: Path, model_size: str, lang: str, karaoke: bool) -> Path:
    label = "カラオケモード" if karaoke else "通常モード"
    print(f"[3/8] 文字起こし中... (モデル: {model_size} / {label})")
    from faster_whisper import WhisperModel

    model = WhisperModel(model_size, device="cpu", compute_type="int8")
    segments, info = model.transcribe(str(input_file), language=lang, beam_size=5, word_timestamps=True)
    seg_list = list(segments)
    print(f"  言語: {info.language} (確信度: {info.language_probability:.0%})")

    # SRTは常に生成（Claudeチェック用）
    with open(srt_file, "w", encoding="utf-8") as f:
        for i, seg in enumerate(seg_list, 1):
            f.write(f"{i}\n{fmt_srt(seg.start)} --> {fmt_srt(seg.end)}\n{seg.text.strip()}\n\n")

    if karaoke:
        ass_file = srt_file.with_suffix(".ass")
        _write_karaoke_ass(seg_list, ass_file)
        return ass_file

    # 通常モードもASSに変換（位置制御を確実にするため）
    ass_file = srt_file.with_suffix(".ass")
    _write_simple_ass(srt_file, ass_file)
    return ass_file


ASS_HEADER = f"""\
[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
ScaledBorderAndShadow: yes
WrapStyle: 1

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Hiragino Sans,{SUBTITLE_FONT_SIZE},&H00FFFFFF,&H0000FFFF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,3,1,2,{SUBTITLE_MARGIN_LR},{SUBTITLE_MARGIN_LR},{SUBTITLE_MARGIN_V},1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"""


def _write_simple_ass(srt_file: Path, ass_file: Path):
    """SRTをシンプルなASSに変換（底部中央・白文字・黒縁）"""
    content = srt_file.read_text(encoding="utf-8")
    blocks = content.strip().split("\n\n")
    lines = [ASS_HEADER]
    for block in blocks:
        parts = block.split("\n")
        if len(parts) < 3:
            continue
        # タイムスタンプ変換（SRT → ASS）
        ts = parts[1].replace(",", ".")
        start, end = ts.split(" --> ")
        # 秒の小数点以下2桁に丸める
        def to_ass_ts(t):
            t = t.strip()
            h, m, s = t.split(":")
            return f"{int(h)}:{m}:{float(s):05.2f}"
        # テキスト（複数行を\Nで結合）
        text = r"\N".join(p.strip() for p in parts[2:] if p.strip())
        lines.append(
            f"Dialogue: 0,{to_ass_ts(start)},{to_ass_ts(end)},"
            f"Default,,0,0,0,,{text}"
        )
    ass_file.write_text("\n".join(lines), encoding="utf-8")


def _write_karaoke_ass(segments, ass_file: Path):
    lines = [ASS_HEADER]
    for seg in segments:
        if seg.words:
            text = "".join(f"{{\\k{int((w.end - w.start)*100)}}}{w.word.strip()} " for w in seg.words).strip()
        else:
            text = seg.text.strip()
        lines.append(f"Dialogue: 0,{fmt_ass(seg.start)},{fmt_ass(seg.end)},Default,,0,0,0,,{text}")
    ass_file.write_text("\n".join(lines), encoding="utf-8")
    print(f"  → {ass_file.name} (カラオケASS)")


# ─────────────────────────────────────────────
# Step 4: Claude APIで字幕セルフチェック
# ─────────────────────────────────────────────

def correct_srt_with_claude(srt_file: Path) -> list:
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not api_key:
        print("[4/8] Claude字幕チェック → ANTHROPIC_API_KEY未設定のためスキップ")
        return []
    print("[4/8] Claude APIで字幕チェック中...")
    import anthropic

    content = srt_file.read_text(encoding="utf-8")
    client = anthropic.Anthropic(api_key=api_key)
    resp = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=2000,
        messages=[{"role": "user", "content": f"""以下はWhisperが生成したSRT字幕です。日本語として不自然な箇所・誤認識された漢字・文脈に合わない語句を修正してください。

ルール:
- SRTの形式（番号・タイムスタンプ行）は一切変えない
- テキスト行のみ修正する
- 出力は必ず以下の形式で返す

---SRT---
（修正済みSRTをそのまま）
---修正箇所---
（「元の語句 → 修正後」を1行ずつ。修正なしなら「修正なし」）

SRT:
{content}"""}]
    )
    parts = resp.content[0].text.split("---修正箇所---")
    if len(parts) == 2:
        corrected = parts[0].replace("---SRT---", "").strip()
        fixes = [l for l in parts[1].strip().split("\n") if l.strip() and l.strip() != "修正なし"]
        srt_file.write_text(corrected, encoding="utf-8")
        if fixes:
            print(f"  修正 {len(fixes)}件:")
            for f in fixes: print(f"    {f}")
        else:
            print("  修正なし（字幕は正確）")
        return fixes
    print("  ⚠ レスポンス解析失敗 → 元のSRTを使用")
    return []


# ─────────────────────────────────────────────
# Step 5: 字幕焼き込み + タイトル + フェード
# ─────────────────────────────────────────────

def burn_and_finalize(input_file: Path, subtitle_file: Path, output_file: Path, title, fade_sec: float):
    print("[5/8] 字幕・タイトル・フェード処理中...")
    dur = get_video_info(input_file)["duration"]
    fade_out = max(0, dur - fade_sec)
    is_ass = subtitle_file.suffix == ".ass"
    sub_esc = str(subtitle_file).replace("\\", "\\\\").replace(":", "\\:")

    vf = []
    vf.append(f"ass='{sub_esc}'" if is_ass else f"subtitles='{sub_esc}':force_style='{TIKTOK_STYLE}'")

    if title:
        safe = title.replace("'", "\\'").replace(":", "\\:")
        vf.append(
            f"drawtext=text='{safe}':fontsize=52:fontcolor=white"
            f":borderw=3:bordercolor=black"
            f":x=(w-text_w)/2:y=(h/2)-60:enable='between(t,0,3)'"
        )

    vf.append(f"fade=t=in:st=0:d={fade_sec}")
    vf.append(f"fade=t=out:st={fade_out:.2f}:d={fade_sec}")
    af = [f"afade=t=in:st=0:d={fade_sec}", f"afade=t=out:st={fade_out:.2f}:d={fade_sec}"]

    subprocess.run([
        "ffmpeg", "-i", str(input_file),
        "-vf", ",".join(vf),
        "-af", ",".join(af),
        "-c:v", "libx264", "-crf", "22",
        "-c:a", "aac", "-b:a", "128k",
        "-y", str(output_file)
    ], check=True, capture_output=True)
    print(f"  → {output_file.name}")


# ─────────────────────────────────────────────
# Step 6: BGMダウンロード＆合成
# ─────────────────────────────────────────────

def download_bgm(genre: str, bgm_dir: Path):
    bgm_dir.mkdir(parents=True, exist_ok=True)
    cached = list(bgm_dir.glob(f"{genre}_*.mp3"))
    if cached:
        print(f"  キャッシュBGM使用: {cached[0].name}")
        return cached[0]
    query = BGM_SEARCH.get(genre, BGM_SEARCH["pop"])
    tmpl = str(bgm_dir / f"{genre}_%(id)s")
    print(f"  BGMダウンロード中... (ジャンル: {genre})")
    subprocess.run([
        "yt-dlp", f"ytsearch1:{query}",
        "-x", "--audio-format", "mp3", "--audio-quality", "128K",
        "-o", tmpl, "--no-playlist"
    ], capture_output=True, text=True)
    found = list(bgm_dir.glob(f"{genre}_*.mp3"))
    if found: return found[0]
    print("  ⚠ BGMダウンロード失敗 → スキップ")
    return None


def add_bgm(input_file: Path, bgm_file: Path, output_file: Path, vol: float):
    """サイドチェイン圧縮でボイス優先BGM合成。声がある時はBGMを自動ダッキング。"""
    print(f"[6/8] BGM合成中... (ボイスダッキング / BGM基準音量: {int(vol*100)}%)")
    dur = get_video_info(input_file)["duration"]
    fade_out = max(0, dur - 1.5)

    # ボイス正規化 → BGMダッキング → ミックス
    filter_complex = (
        f"[0:a]loudnorm=I=-14:LRA=11:TP=-1.5,asplit=2[voice_main][voice_side];"
        f"[1:a]volume={vol},afade=t=out:st={fade_out:.2f}:d=1.5[bgm_raw];"
        f"[bgm_raw][voice_side]sidechaincompress="
        f"threshold=0.02:ratio=8:attack=100:release=800[bgm_ducked];"
        f"[voice_main][bgm_ducked]amix=inputs=2:duration=first:dropout_transition=2[aout]"
    )
    subprocess.run([
        "ffmpeg",
        "-i", str(input_file),
        "-stream_loop", "-1", "-i", str(bgm_file),
        "-filter_complex", filter_complex,
        "-map", "0:v", "-map", "[aout]",
        "-c:v", "copy", "-shortest",
        "-y", str(output_file)
    ], check=True, capture_output=True)
    print(f"  → {output_file.name}")


# ─────────────────────────────────────────────
# Step 7: 尺カット
# ─────────────────────────────────────────────

def trim_duration(input_file: Path, output_file: Path, max_dur: float):
    info = get_video_info(input_file)
    if info["duration"] <= max_dur:
        shutil.copy(str(input_file), str(output_file))
        return
    print(f"[7/8] 尺カット: {info['duration']:.1f}s → {max_dur}s")
    subprocess.run([
        "ffmpeg", "-i", str(input_file),
        "-t", str(max_dur), "-c", "copy",
        "-y", str(output_file)
    ], check=True, capture_output=True)
    print(f"  → {output_file.name}")


# ─────────────────────────────────────────────
# Step 8: サムネイル生成
# ─────────────────────────────────────────────

def generate_thumbnail(input_file: Path, output_file: Path):
    print("[8/8] サムネイル生成中...")
    dur = get_video_info(input_file)["duration"]
    subprocess.run([
        "ffmpeg", "-ss", str(dur / 3),
        "-i", str(input_file),
        "-vframes", "1", "-q:v", "2",
        "-y", str(output_file)
    ], check=True, capture_output=True)
    print(f"  → {output_file.name}")


# ─────────────────────────────────────────────
# メインパイプライン（1ファイル）
# ─────────────────────────────────────────────

def process_file(input_path: Path, args, output_dir: Path):
    preset = PRESETS.get(args.preset, PRESETS["default"])
    stem = input_path.stem
    print(f"\n━━━ {input_path.name} ━━━ [{args.preset}]")

    with tempfile.TemporaryDirectory() as tmp_:
        tmp = Path(tmp_)

        # 1. 前処理
        step1 = tmp / f"{stem}_pre.mp4"
        preprocess(input_path, step1, preset, not args.no_enhance)

        # 2. 無音カット
        step2 = tmp / f"{stem}_sil.mp4"
        cut_silence(step1, step2, args.silence_db, args.silence_sec)

        # 3. 文字起こし
        srt = tmp / f"{stem}.srt"
        subtitle_file = transcribe(step2, srt, args.model, args.lang, args.karaoke)

        # 4. Claude字幕チェック（SRTのみ）
        corrections = correct_srt_with_claude(srt)
        if not args.karaoke:
            wrap_srt_file(srt)

        # 5. 字幕焼き込み＋タイトル＋フェード
        step5 = tmp / f"{stem}_sub.mp4"
        burn_and_finalize(step2, subtitle_file, step5, args.title, fade_sec=0.5)

        # 6. BGM
        bgm_path = None
        if args.bgm:
            bgm_path = Path(args.bgm)
        elif args.download_bgm:
            bgm_path = download_bgm(args.bgm_genre, BGM_DIR)

        step6 = tmp / f"{stem}_bgm.mp4"
        if bgm_path and bgm_path.exists():
            add_bgm(step5, bgm_path, step6, args.bgm_vol)
        else:
            if not args.bgm and not args.download_bgm:
                print("[6/8] BGMなし → スキップ")
            shutil.copy(str(step5), str(step6))

        # 7. 尺カット
        max_dur = preset.get("max_duration")
        step7 = tmp / f"{stem}_trim.mp4"
        if max_dur:
            trim_duration(step6, step7, max_dur)
        else:
            print("[7/8] 尺カットなし → スキップ")
            shutil.copy(str(step6), str(step7))

        # 出力
        final = output_dir / f"{stem}_final.mp4"
        srt_out = output_dir / f"{stem}.srt"
        thumb = output_dir / f"{stem}_thumb.jpg"
        shutil.copy(str(step7), str(final))
        shutil.copy(str(srt), str(srt_out))

        # 8. サムネイル
        generate_thumbnail(final, thumb)

    print(f"\n✓ 完成動画:   {final}")
    print(f"✓ 字幕:       {srt_out}")
    print(f"✓ サムネイル: {thumb}")
    if corrections:
        print(f"✓ 字幕修正:   {len(corrections)}件適用済み")
    return final


# ─────────────────────────────────────────────
# エントリーポイント
# ─────────────────────────────────────────────

def resolve_input(arg: str) -> Path:
    p = Path(arg)
    if p.exists(): return p
    dl = DOWNLOADS / arg
    if dl.exists(): return dl
    raise FileNotFoundError(f"ファイルが見つかりません: {arg}")


def main():
    parser = argparse.ArgumentParser(description="縦型動画編集パイプライン v2")
    parser.add_argument("input", help="動画ファイルまたはディレクトリ（バッチ処理）")
    parser.add_argument("--preset", default="tiktok", choices=list(PRESETS.keys()))
    parser.add_argument("--bgm", default=None, help="BGMファイルパス")
    parser.add_argument("--download-bgm", action="store_true", help="BGMを自動ダウンロード")
    parser.add_argument("--bgm-genre", default="pop", choices=list(BGM_SEARCH.keys()))
    parser.add_argument("--bgm-vol", default=0.18, type=float)
    parser.add_argument("--model", default="medium", choices=["tiny", "base", "small", "medium", "large"])
    parser.add_argument("--lang", default="ja")
    parser.add_argument("--karaoke", action="store_true", help="カラオケ風ワードハイライト字幕")
    parser.add_argument("--title", default=None, help="冒頭3秒に表示するタイトルテキスト")
    parser.add_argument("--no-enhance", action="store_true", help="明るさ・コントラスト補正をスキップ")
    parser.add_argument("--silence-db", default=-35.0, type=float)
    parser.add_argument("--silence-sec", default=0.5, type=float)
    parser.add_argument("--output-dir", default=None)
    args = parser.parse_args()

    input_path = resolve_input(args.input)

    if input_path.is_dir():
        exts = {".mp4", ".mov", ".avi", ".mkv", ".m4v"}
        files = sorted(f for f in input_path.iterdir() if f.suffix.lower() in exts)
        if not files:
            print(f"動画ファイルが見つかりません: {input_path}")
            return
        print(f"バッチ処理: {len(files)}ファイル")
        output_dir = Path(args.output_dir) if args.output_dir else input_path / "_output"
        output_dir.mkdir(parents=True, exist_ok=True)
        for f in files:
            process_file(f, args, output_dir)
    else:
        output_dir = Path(args.output_dir) if args.output_dir else input_path.parent
        output_dir.mkdir(parents=True, exist_ok=True)
        process_file(input_path, args, output_dir)


if __name__ == "__main__":
    main()
