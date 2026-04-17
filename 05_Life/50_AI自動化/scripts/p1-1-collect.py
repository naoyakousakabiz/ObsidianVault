#!/usr/bin/env python3
from __future__ import annotations

import argparse
import html
import json
import os
import re
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from datetime import datetime, timedelta
from email.utils import parsedate_to_datetime
from pathlib import Path
from typing import Iterable
from zoneinfo import ZoneInfo

JST = ZoneInfo("Asia/Tokyo")
USER_AGENT = "Mozilla/5.0 (compatible; p1-1-collector/1.0)"
RSS_FEEDS = [
    ("AGIラボ", "https://note.com/chatgpt_lab/rss"),
    ("ITmedia AI+", "https://rss.itmedia.co.jp/rss/2.0/aiplus.xml"),
    ("日経クロステック", "https://xtech.nikkei.com/rss/index.rdf"),
]
# channel_id をハードコードして毎回の HTML フェッチを省略
YOUTUBE_CHANNELS = [
    ("KEITO【AI&WEB ch】", "UCfapRkagDtoQEkGeyD3uERQ"),
    ("チャエン【AI研究所】", "UC9buL3Iph_f7AZxdzmiBL8Q"),
    ("ジェネトピ", "UCL68L-bhupBuuVhAfCN8VlQ"),
    ("あなたのAI顧問", "UCs4JETeUDLunGHzGU0mB1Vg"),
    ("PIVOT 公式チャンネル", "UC8yHePe_RgUBE-waRWy6olw"),
]
# X 収集対象アカウント（RT除外・本人投稿のみ）
X_ACCOUNTS = [
    # AI活用
    "ai_shunoda", "Hoshino_AISales", "kandmybike", "Shimayus", "kajikent",
    "itm_aiplus", "tetumemo", "keitowebai", "usutaku_channel", "SuguruKun_ai",
    "masahirochaen", "claudecode_lab", "L_go_mrk", "yusaku_0426", "daifukujinji",
    "kawai_design", "ayami_marketing", "ai_jitan",
    # AIビジネス/未来
    "fukkyy", "saasmeshi", "hayakawagomi", "tsuchinao83", "shin_sasaki19",
    # 教養・SaaS・CS
    "naikoutetsugaku", "allstarsaasfund", "tsukasa_sherpa", "kajisan_cs",
]
PRIORITY_KEYWORDS = [
    "Claude",
    "ChatGPT",
    "Gemini",
    "Cursor",
    "MCP",
    "AIエージェント",
    "自動化",
    "ワークフロー",
]
RECENT_WINDOW_HOURS = 24
SLACK_TOPICS_LIMIT = 3
# 24h内の更新を全件見せる運用に変更（上限なし）
RSS_DAILY_LIMIT = 999
YOUTUBE_DAILY_LIMIT = 999
WEB_DISPLAY_LIMIT = 10
YOUTUBE_TRANSCRIPT_TOP_N = 2
X_MIN_LIKES = 100
X_DAILY_LIMIT = 5
AI_NEWS_TOP_LIMIT = 5
AI_NEWS_FEED = ("AI速報", "https://news.google.com/rss/search?q=AI+when:1d&hl=ja&gl=JP&ceid=JP:ja")


@dataclass
class Entry:
    section: str
    source: str
    title: str
    url: str
    published: datetime
    summary: str
    priority: int


def fetch_text(url: str, timeout: int = 20) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        return response.read().decode(charset, errors="replace")


def clean_text(text: str) -> str:
    text = html.unescape(text or "")
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def summarize(text: str, limit: int = 90) -> str:
    text = clean_text(text)
    if not text:
        return "要約なし"
    if len(text) <= limit:
        return text
    return text[: limit - 1].rstrip() + "…"


def summarize_from_title(title: str, limit: int = 90) -> str:
    cleaned = clean_text(title)
    cleaned = re.sub(r"【[^】]*】", "", cleaned).strip()
    chunks = [x.strip() for x in re.split(r"[／/|｜・]", cleaned) if x.strip()]
    if not chunks:
        return summarize(cleaned, limit=limit)
    return summarize(" / ".join(chunks[:3]), limit=limit)


def parse_date(raw: str | None) -> datetime | None:
    if not raw:
        return None
    raw = raw.strip()
    try:
        dt = parsedate_to_datetime(raw)
    except (TypeError, ValueError, IndexError):
        dt = None
    if dt is None:
        normalized = raw.replace("Z", "+00:00")
        try:
            dt = datetime.fromisoformat(normalized)
        except ValueError:
            return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=JST)
    return dt.astimezone(JST)


def get_child_text(node: ET.Element, names: Iterable[str]) -> str:
    for name in names:
        child = node.find(name)
        if child is not None and child.text:
            return child.text.strip()
    return ""


def iter_feed_entries(xml_text: str, source_name: str, section: str) -> list[Entry]:
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError as exc:
        raise RuntimeError(f"XML解析失敗 [{source_name}]: {exc}") from exc
    entries: list[Entry] = []
    atom_ns = {"atom": "http://www.w3.org/2005/Atom"}
    rdf_ns = {"rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#"}

    if root.tag.endswith("feed"):
        nodes = root.findall("atom:entry", atom_ns)
    elif root.tag.endswith("RDF"):
        nodes = root.findall("item")
        if not nodes:
            nodes = root.findall("rdf:item", rdf_ns)
    else:
        channel = root.find("channel")
        nodes = channel.findall("item") if channel is not None else []

    for node in nodes:
        title = get_child_text(node, ["title", "{http://www.w3.org/2005/Atom}title"])
        if not title:
            continue
        link = ""
        atom_link = node.find("{http://www.w3.org/2005/Atom}link")
        if atom_link is not None:
            link = atom_link.attrib.get("href", "").strip()
        if not link:
            link = get_child_text(node, ["link"])
        if not link:
            continue
        raw_date = get_child_text(
            node,
            [
                "pubDate",
                "dc:date",
                "{http://purl.org/dc/elements/1.1/}date",
                "{http://www.w3.org/2005/Atom}published",
                "{http://www.w3.org/2005/Atom}updated",
            ],
        )
        published = parse_date(raw_date)
        if published is None:
            continue
        description = get_child_text(
            node,
            [
                "description",
                "content:encoded",
                "{http://purl.org/rss/1.0/modules/content/}encoded",
                "{http://www.w3.org/2005/Atom}summary",
            ],
        )
        summary = summarize(description or title)
        priority = compute_priority(title, summary)
        entries.append(Entry(section, source_name, clean_text(title), link.strip(), published, summary, priority))
    return entries


def compute_priority(title: str, summary: str) -> int:
    haystack = f"{title} {summary}".lower()
    for index, keyword in enumerate(PRIORITY_KEYWORDS):
        if keyword.lower() in haystack:
            return index
    return len(PRIORITY_KEYWORDS) + 1


def youtube_feed_url(channel_id: str) -> str:
    return f"https://www.youtube.com/feeds/videos.xml?channel_id={channel_id}"


def in_recent_window(dt: datetime, now: datetime, hours: int = RECENT_WINDOW_HOURS) -> bool:
    lower_bound = now - timedelta(hours=hours)
    target = dt.astimezone(JST)
    return lower_bound <= target <= now


def sort_entries(entries: list[Entry]) -> list[Entry]:
    return sorted(entries, key=lambda item: (item.priority, -item.published.timestamp(), item.title))


def normalize_for_compare(text: str) -> str:
    text = clean_text(text).lower()
    text = re.sub(r"[【】\[\]()（）「」『』:：\-_/|｜・,.。、…!！?？\s]", "", text)
    return text


def is_too_similar(title: str, summary: str) -> bool:
    t = normalize_for_compare(title)
    s = normalize_for_compare(summary)
    if not t or not s:
        return False
    if t == s or t in s or s in t:
        return True
    t_set = set(re.findall(r"[a-z0-9\u3040-\u30ff\u4e00-\u9fff]{2,}", t))
    s_set = set(re.findall(r"[a-z0-9\u3040-\u30ff\u4e00-\u9fff]{2,}", s))
    if not t_set or not s_set:
        return False
    overlap = len(t_set & s_set) / max(1, len(t_set | s_set))
    return overlap >= 0.8


def build_distinct_brief(title: str, summary: str) -> str:
    points = [x.strip() for x in re.split(r"[／/|｜・]", clean_text(title)) if x.strip()]
    points = [p for p in points if len(p) >= 4][:3]
    if points:
        return summarize(f"主題: {points[0]} / 論点: {' / '.join(points[1:]) if len(points) > 1 else '要確認'}", limit=90)
    return summarize(summary, limit=90)


def build_slack_topics(entries: list[Entry], limit: int = SLACK_TOPICS_LIMIT) -> list[str]:
    topics: list[str] = []
    for entry in entries[:limit]:
        brief = summarize(entry.summary, limit=80)
        if brief == "要約なし" or len(brief) < 20:
            brief = summarize(f"{entry.title} {entry.summary}", limit=80)
        if is_too_similar(entry.title, brief):
            brief = build_distinct_brief(entry.title, entry.summary)
        topics.append(
            f"- {entry.title}（{entry.source}）\n"
            f"  要点: {brief}\n"
            f"  URL: {entry.url}"
        )
    return topics


def build_ai_news_briefs(entries: list[Entry], limit: int = AI_NEWS_TOP_LIMIT) -> list[str]:
    briefs: list[str] = []
    for i, entry in enumerate(entries[:limit], start=1):
        brief = summarize_from_title(entry.title, limit=52)
        if is_too_similar(entry.title, brief):
            brief = summarize(entry.summary, limit=52)
        briefs.append(
            f"{i}. {brief}\n"
            f"   🔗 <{entry.url}|記事を開く>"
        )
    return briefs


def build_youtube_channel_digest(entries: list[Entry]) -> list[str]:
    """チャンネル単位でまとめる（1チャンネル1ブロック・優先度順）"""
    channels: dict[str, list[Entry]] = {}
    for entry in entries:
        channels.setdefault(entry.source, []).append(entry)
    ordered = sorted(channels.items(), key=lambda kv: min(e.priority for e in kv[1]))
    blocks = []
    for channel, ch_entries in ordered:
        count = len(ch_entries)
        points = " / ".join(summarize_from_title(e.title, limit=35) for e in ch_entries[:3])
        urls = [f"  {e.url}" for e in ch_entries[:3]]
        blocks.append("\n".join([f"▶ {channel}（{count}本）", f"  {points}", *urls]))
    return blocks


def build_numbered_section(entries: list[Entry], display_limit: int) -> str:
    if not entries:
        return "- 該当なし"
    items = []
    for i, entry in enumerate(entries[:display_limit], start=1):
        brief = summarize(entry.summary, limit=80)
        if brief == "要約なし" or len(brief) < 15:
            brief = summarize_from_title(entry.title, limit=80)
        items.append(
            f"{i}) {entry.title}\n"
            f"   {brief}\n"
            f"   🔗 <{entry.url}|開く>（{entry.source}）"
        )
    result = "\n\n".join(items)
    remaining = len(entries) - display_limit
    if remaining > 0:
        result += f"\n\n…（残り{remaining}件は省略）"
    return result


def load_previous_urls(path: Path) -> set[str]:
    if not path.exists():
        return set()
    # Markdown末尾の ) > " ' を除いてURLを正確に抽出する
    return set(re.findall(r"https?://[^\s)>\"']+", path.read_text(encoding="utf-8")))


def fetch_x_entries(
    api_key: str,
    now_jst: datetime,
    prev_urls: set[str],
    errors: list[str],
) -> list[Entry]:
    if not X_ACCOUNTS:
        return []
    from_query = " OR ".join(f"from:{a}" for a in X_ACCOUNTS)
    query = f"({from_query}) -is:retweet -is:reply"
    params = urllib.parse.urlencode({
        "query": query,
        "queryType": "Latest",
    })
    url = f"https://api.twitterapi.io/twitter/tweet/advanced_search?{params}"
    req = urllib.request.Request(
        url,
        headers={"X-API-Key": api_key, "User-Agent": USER_AGENT},
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        errors.append(f"X取得失敗: HTTP {exc.code}")
        return []
    except Exception as exc:  # noqa: BLE001
        errors.append(f"X取得失敗: {exc}")
        return []

    tweets = data.get("tweets", [])
    if not tweets and data.get("msg"):
        errors.append(f"X API エラー: {data['msg']}")
        return []

    entries: list[Entry] = []
    for tweet in tweets:
        published = parse_date(tweet.get("createdAt"))
        if not published or not in_recent_window(published, now_jst):
            continue
        like_count = tweet.get("likeCount", 0) or 0
        if like_count < X_MIN_LIKES:
            continue
        text = clean_text(tweet.get("text", ""))
        if not any(kw.lower() in text.lower() for kw in PRIORITY_KEYWORDS):
            continue
        username = tweet.get("author", {}).get("userName", "unknown")
        tweet_id = tweet.get("id", "")
        tweet_url = tweet.get("url") or f"https://x.com/{username}/status/{tweet_id}"
        if tweet_url in prev_urls:
            continue
        retweet_count = tweet.get("retweetCount", 0) or 0
        summary = f"👍 {like_count:,} / RT {retweet_count:,}"
        priority = compute_priority(text, "")
        entries.append(Entry(
            section="x",
            source=f"@{username}",
            title=summarize(text, limit=80),
            url=tweet_url,
            published=published,
            summary=summary,
            priority=priority,
        ))
    return sort_entries(entries)[:X_DAILY_LIMIT]


def build_slack_message(
    date_str: str,
    rss_entries: list[Entry],
    youtube_entries: list[Entry],
    x_entries: list[Entry],
) -> str:
    total = len(rss_entries) + len(youtube_entries) + len(x_entries)
    updates_24h = sort_entries(rss_entries + youtube_entries + x_entries)
    lines = [
        f"📥 *Life Info* [{date_str}] <@U0ARZH32TSQ>",
        "",
        "━━━━━━━━━━━━━━━━━━",
        "📊 *件数サマリ*",
        f"・Web記事: {len(rss_entries)}件（24h）",
        f"・YouTube: {len(youtube_entries)}件（24h）",
        f"・X: {len(x_entries)}件（24h）",
        f"・合計: {total}件",
    ]
    ai_news_entries = [e for e in updates_24h if e.section == "rss" and e.source == AI_NEWS_FEED[0]]
    ai_news = build_ai_news_briefs(ai_news_entries, limit=min(len(ai_news_entries), AI_NEWS_TOP_LIMIT))
    if ai_news:
        lines.extend(["", "━━━━━━━━━━━━━━━━━━", "🧠 *AIニュース TOP5*（24h）", *ai_news])
    else:
        lines.extend(["", "━━━━━━━━━━━━━━━━━━", "🧠 *AIニュース TOP5*（24h）", "- 該当なし"])
    web_filtered = [e for e in updates_24h if e.section == "rss" and e.source != AI_NEWS_FEED[0]]
    web_section = build_numbered_section(web_filtered, WEB_DISPLAY_LIMIT)
    lines.extend(["", "━━━━━━━━━━━━━━━━━━", f"📰 *Web記事*（24h・{len(web_filtered)}件）", web_section])
    yt_filtered = [e for e in updates_24h if e.section == "youtube"]
    yt_section = build_numbered_section(yt_filtered, len(yt_filtered))
    lines.extend(["", "━━━━━━━━━━━━━━━━━━", f"▶️ *YouTube*（24h・{len(yt_filtered)}件）", yt_section])
    x_updates = build_slack_topics([e for e in updates_24h if e.section == "x"], limit=len(x_entries))
    lines.extend(["", "━━━━━━━━━━━━━━━━━━", f"𝕏 *X*（24h・{len(x_entries)}件）", *(x_updates if x_updates else ["- 該当なし"])])
    lines.extend([
        "",
        "━━━━━━━━━━━━━━━━━━",
        f"保存先: `20_Input/05_日次情報収集/{date_str}_collect.md`",
    ])
    return "\n".join(lines)


def extract_youtube_video_id(url: str) -> str | None:
    parsed = urllib.parse.urlparse(url)
    if parsed.netloc.endswith("youtu.be"):
        return parsed.path.strip("/").split("/")[0] or None
    if "youtube.com" in parsed.netloc:
        video_id = urllib.parse.parse_qs(parsed.query).get("v", [""])[0]
        return video_id or None
    return None


def fetch_youtube_transcript(video_id: str) -> str | None:
    # 取得できる字幕のみ使う（未提供動画は通常要約へフォールバック）
    candidates = [
        {"lang": "ja"},
        {"lang": "ja", "kind": "asr"},
        {"lang": "en"},
        {"lang": "en", "kind": "asr"},
    ]
    for params in candidates:
        query = {"v": video_id, **params}
        url = f"https://www.youtube.com/api/timedtext?{urllib.parse.urlencode(query)}"
        try:
            body = fetch_text(url)
        except Exception:  # noqa: BLE001
            continue
        if "<text" not in body:
            continue
        try:
            root = ET.fromstring(body)
        except ET.ParseError:
            continue
        chunks = [clean_text("".join(node.itertext())) for node in root.findall("text")]
        transcript = " ".join(x for x in chunks if x).strip()
        if transcript:
            return transcript
    return None


def enrich_youtube_summaries(entries: list[Entry], errors: list[str]) -> None:
    for entry in entries[:YOUTUBE_TRANSCRIPT_TOP_N]:
        video_id = extract_youtube_video_id(entry.url)
        if not video_id:
            continue
        transcript = fetch_youtube_transcript(video_id)
        if transcript:
            entry.summary = summarize(transcript, limit=140)
        else:
            errors.append(f"YouTube字幕未取得 [{entry.source}]: {entry.title}")
    for entry in entries:
        if entry.summary == "要約なし" or len(entry.summary) < 24 or clean_text(entry.summary) == clean_text(entry.title):
            entry.summary = summarize_from_title(entry.title, limit=140)
            # タイトルフォールバックはINFO（エラーではない）
            print(f"[INFO] YouTube要約: タイトルから生成 [{entry.source}]: {entry.title}")


def select_rss_feeds(include_csv: str) -> list[tuple[str, str]]:
    if not include_csv.strip():
        return RSS_FEEDS
    includes = {x.strip() for x in include_csv.split(",") if x.strip()}
    selected = [feed for feed in RSS_FEEDS if feed[0] in includes]
    return selected if selected else RSS_FEEDS


def format_entry(entry: Entry, is_youtube: bool) -> str:
    timestamp = entry.published.strftime("%Y-%m-%d" if is_youtube else "%Y-%m-%d %H:%M")
    return f"- **{entry.title}** ({entry.source}) [{timestamp}]\n  {entry.url}\n  > {entry.summary}\n"


def build_markdown(
    today_str: str,
    rss_entries: list[Entry],
    youtube_entries: list[Entry],
    x_entries: list[Entry],
) -> str:
    total = len(rss_entries) + len(youtube_entries) + len(x_entries)
    lines = [
        "---",
        f"date: {today_str}",
        "type: rss-collect",
        "domain: life",
        "status: active",
        "source: auto-sync",
        "tags: [rss, youtube, x, collect]",
        "---",
        "",
        f"# 情報収集 {today_str}",
        "",
        f"**件数:** RSS {len(rss_entries)}件 / YouTube {len(youtube_entries)}件 / X {len(x_entries)}件 / 計{total}件",
        "",
        "## RSS",
        "",
    ]
    if rss_entries:
        for entry in rss_entries:
            lines.append(format_entry(entry, False).rstrip())
            lines.append("")
    else:
        lines.extend(["- 該当なし", ""])
    lines.extend(["## YouTube", ""])
    if youtube_entries:
        for entry in youtube_entries:
            lines.append(format_entry(entry, True).rstrip())
            lines.append("")
    else:
        lines.extend(["- 該当なし", ""])
    lines.extend(["## X", ""])
    if x_entries:
        for entry in x_entries:
            lines.append(format_entry(entry, False).rstrip())
            lines.append("")
    else:
        lines.extend(["- 該当なし", ""])
    return "\n".join(lines).rstrip() + "\n"


def write_markdown(output_path: Path, content: str) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    tmp_path = output_path.with_suffix(output_path.suffix + ".tmp")
    try:
        tmp_path.write_text(content, encoding="utf-8")
        tmp_path.replace(output_path)
    except OSError as exc:
        raise RuntimeError(f"ファイル書き込み失敗: {output_path} ({exc})") from exc


def send_slack_message(token: str, channel_id: str, message: str) -> None:
    payload = json.dumps({"channel": channel_id, "text": message}).encode("utf-8")
    request = urllib.request.Request(
        "https://slack.com/api/chat.postMessage",
        data=payload,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json; charset=utf-8",
            "User-Agent": USER_AGENT,
        },
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        body = json.loads(response.read().decode("utf-8"))
    if not body.get("ok"):
        raise RuntimeError(f"Slack通知失敗: {body}")


def is_bot_token(token: str) -> bool:
    return token.startswith("xoxb-")


def env_int(name: str, default: int) -> int:
    raw = os.environ.get(name)
    if raw is None or not raw.strip():
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def env_bool(name: str, default: bool) -> bool:
    raw = os.environ.get(name)
    if raw is None or not raw.strip():
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--date", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--previous-file", required=True)
    parser.add_argument("--slack-channel", default="C0ATCP4MTUN")
    args = parser.parse_args()

    # リカバリー実行時の日付ズレ防止: 指定日の23:59:59 と現在時刻の小さい方を上限にする
    date_end = datetime.strptime(args.date, "%Y-%m-%d").replace(
        hour=23, minute=59, second=59, tzinfo=JST
    )
    now_jst = min(datetime.now(JST), date_end)

    output_path = Path(args.output)
    prev_urls = load_previous_urls(Path(args.previous_file))
    rss_entries: list[Entry] = []
    youtube_entries: list[Entry] = []
    x_entries: list[Entry] = []
    errors: list[str] = []

    rss_feeds = select_rss_feeds(os.environ.get("P11_RSS_INCLUDE", ""))

    for source, url in rss_feeds:
        try:
            for entry in iter_feed_entries(fetch_text(url), source, "rss"):
                if not in_recent_window(entry.published, now_jst):
                    continue
                if entry.url in prev_urls:
                    continue
                rss_entries.append(entry)
        except Exception as exc:  # noqa: BLE001
            errors.append(f"RSS取得失敗 [{source}]: {exc}")

    # Webリサーチ枠: 24hのAIニュースを追加（重複URLは除外）
    try:
        source, url = AI_NEWS_FEED
        for entry in iter_feed_entries(fetch_text(url), source, "rss"):
            if not in_recent_window(entry.published, now_jst):
                continue
            if any(e.url == entry.url for e in rss_entries):
                continue
            rss_entries.append(entry)
    except Exception as exc:  # noqa: BLE001
        errors.append(f"AIニュース取得失敗 [{AI_NEWS_FEED[0]}]: {exc}")

    for source, channel_id in YOUTUBE_CHANNELS:
        try:
            feed_url = youtube_feed_url(channel_id)
            for entry in iter_feed_entries(fetch_text(feed_url), source, "youtube"):
                if not in_recent_window(entry.published, now_jst):
                    continue
                if entry.url in prev_urls:
                    continue
                youtube_entries.append(entry)
        except Exception as exc:  # noqa: BLE001
            errors.append(f"YouTube取得失敗 [{source}]: {exc}")

    twitterapi_key = os.environ.get("TWITTERAPI_IO_KEY")
    if twitterapi_key:
        x_min_likes = env_int("X_MIN_LIKES", 30)
        x_require_keywords = env_bool("X_REQUIRE_PRIORITY_KEYWORDS", False)

        # 実運用では0件回避を優先。条件は環境変数で厳しく戻せるようにする。
        global X_MIN_LIKES  # noqa: PLW0603
        X_MIN_LIKES = x_min_likes

        if not x_require_keywords:
            global PRIORITY_KEYWORDS  # noqa: PLW0603
            PRIORITY_KEYWORDS = []

        x_entries = fetch_x_entries(twitterapi_key, now_jst, prev_urls, errors)
        print(
            f"[INFO] X抽出条件: min_likes={x_min_likes}, require_keywords={x_require_keywords}, accounts={len(X_ACCOUNTS)}"
        )
    else:
        print("[INFO] X収集スキップ: TWITTERAPI_IO_KEY 未設定")

    rss_entries = sort_entries(rss_entries)[:RSS_DAILY_LIMIT]
    youtube_entries = sort_entries(youtube_entries)[:YOUTUBE_DAILY_LIMIT]
    enrich_youtube_summaries(youtube_entries, errors)
    write_markdown(output_path, build_markdown(args.date, rss_entries, youtube_entries, x_entries))

    print(f"RSS {len(rss_entries)}件 / YouTube {len(youtube_entries)}件 / X {len(x_entries)}件 / 計{len(rss_entries) + len(youtube_entries) + len(x_entries)}件")
    for error in errors:
        print(error, file=sys.stderr)

    slack_token = os.environ.get("SLACK_BOT_TOKEN")
    slack_channel = os.environ.get("P11_SLACK_CHANNEL_ID", args.slack_channel)
    if slack_token:
        if not is_bot_token(slack_token):
            print("Slack通知スキップ: xoxb ボットトークンを設定してください", file=sys.stderr)
            return 1
        message = build_slack_message(args.date, rss_entries, youtube_entries, x_entries)
        try:
            send_slack_message(slack_token, slack_channel, message)
            print("Slack通知: 送信成功")
        except Exception as exc:  # noqa: BLE001
            print(f"Slack通知失敗: {exc}", file=sys.stderr)
    else:
        print("Slack通知スキップ: SLACK_BOT_TOKEN 未設定", file=sys.stderr)

    if not rss_entries and not youtube_entries and not x_entries and errors:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
