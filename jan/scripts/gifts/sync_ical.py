#!/usr/bin/env python3
"""Fetch a Google Calendar iCal feed, UPSERT events, queue upcoming birthdays.

Env:
  ICAL_URL   — secret calendar URL (from `pass jan-ical` via jan env.pass)
Optional argv (jan inputs):
  1 horizon_days   — look-ahead window (default 45)
  2 match_regex    — case-insensitive summary filter (default `.` = all events)
  3 feed_file      — read .ics from this path instead of ICAL_URL (offline/demo)
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

import requests
from ical.calendar_stream import IcsCalendarStream

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
try:
    from flow_obs import span_end, span_note, span_start, status_touch, timeline_append
except ImportError:
    def span_start(name: str, **fields: str) -> str:
        return ""

    def span_note(span: str, message: str) -> None:
        return None

    def span_end(span: str) -> None:
        return None

    def timeline_append(prefix: str, line: str, cap: int = 200) -> None:
        return None

    def status_touch(prefix: str, summary: str) -> None:
        return None


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def unifier(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(
        ["unifier", *args],
        check=False,
        text=True,
        encoding="utf-8",
        capture_output=True,
    )
    if check and proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        raise SystemExit(f"gift-sync: unifier {' '.join(args[:3])}… failed: {detail}")
    return proc


def sql_exec(sql: str) -> None:
    unifier("sql", "exec", "gifts", sql)


def sqlq(value: str) -> str:
    return value.replace("'", "''")


def slugify(text: str) -> str:
    s = re.sub(r"[^A-Za-z0-9_-]+", "-", text.strip().lower()).strip("-")
    return s or "unknown"


def person_from_summary(summary: str) -> str:
    cleaned = summary.strip()
    cleaned = re.sub(
        r"(?i)\b(happy\s+)?birthday\b|\bb-?days?\b|\bbdays?\b|\bborn\b",
        " ",
        cleaned,
    )
    cleaned = re.sub(r"(?i)^\s*(of|for|-|:)\s+", "", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip(" -:")
    return cleaned or summary.strip() or "Unknown"


def format_dt(val: date | datetime | None) -> tuple[str | None, int]:
    if val is None:
        return None, 0
    if isinstance(val, datetime):
        if val.tzinfo is None:
            val = val.replace(tzinfo=timezone.utc)
        return val.isoformat(), 0
    if isinstance(val, date):
        return val.isoformat(), 1
    return None, 0


def as_aware(val: date | datetime) -> datetime:
    if isinstance(val, datetime):
        return val if val.tzinfo else val.replace(tzinfo=timezone.utc)
    return datetime(val.year, val.month, val.day, tzinfo=timezone.utc)


def init_schema() -> None:
    sql_exec(
        """
        CREATE TABLE IF NOT EXISTS events (
          uid TEXT PRIMARY KEY,
          summary TEXT,
          description TEXT,
          location TEXT,
          start_time TEXT,
          end_time TEXT,
          is_all_day INTEGER DEFAULT 0,
          person TEXT,
          is_birthday INTEGER DEFAULT 0,
          updated_at TEXT
        );
        CREATE TABLE IF NOT EXISTS ideas (
          person TEXT PRIMARY KEY,
          signal INTEGER,
          drafted_at TEXT
        );
        CREATE TABLE IF NOT EXISTS plans (
          person TEXT PRIMARY KEY,
          planned_at TEXT
        );
        """
    )


def load_ics(feed_file: str) -> str:
    if feed_file:
        return Path(feed_file).expanduser().read_text(encoding="utf-8")
    url = (os.environ.get("ICAL_URL") or "").strip()
    if not url:
        raise SystemExit(
            "gift-sync: ICAL_URL is empty — set via `pass jan-ical` (jan env.pass) "
            "or pass --feed-file"
        )
    # First line only (pass secrets may have trailing notes).
    url = url.splitlines()[0].strip()
    resp = requests.get(
        url,
        timeout=60,
        headers={"User-Agent": "jan-gift-sync/1.0"},
    )
    resp.raise_for_status()
    return resp.text


def main() -> int:
    horizon_days = int((sys.argv[1] if len(sys.argv) > 1 else "45") or "45")
    match_regex = (sys.argv[2] if len(sys.argv) > 2 else ".") or "."
    feed_file = (sys.argv[3] if len(sys.argv) > 3 else "") or ""

    span = span_start("gift-sync", trigger="cron", horizon=str(horizon_days))
    try:
        return _run_sync(horizon_days, match_regex, feed_file, span)
    finally:
        span_end(span)


def _run_sync(horizon_days: int, match_regex: str, feed_file: str, span: str) -> int:
    init_schema()
    raw = load_ics(feed_file)
    calendar = IcsCalendarStream.calendar_from_ics(raw)

    now = utc_now()
    window_end = now + timedelta(days=horizon_days)
    matcher = re.compile(match_regex, re.I)
    now_iso = now.isoformat()

    upsert = """
      INSERT INTO events (
        uid, summary, description, location, start_time, end_time,
        is_all_day, person, is_birthday, updated_at
      ) VALUES (
        '{uid}', '{summary}', '{description}', '{location}', '{start_time}',
        '{end_time}', {is_all_day}, '{person}', {is_birthday}, '{updated_at}'
      )
      ON CONFLICT(uid) DO UPDATE SET
        summary=excluded.summary,
        description=excluded.description,
        location=excluded.location,
        start_time=excluded.start_time,
        end_time=excluded.end_time,
        is_all_day=excluded.is_all_day,
        person=excluded.person,
        is_birthday=excluded.is_birthday,
        updated_at=excluded.updated_at;
    """

    synced = 0
    upcoming: list[dict] = []

    # Recurring birthdays expand here; keep the window tight.
    for event in calendar.timeline.overlapping(now, window_end):
        start_str, is_all_day = format_dt(getattr(event, "start", None))
        end_str, _ = format_dt(getattr(event, "end", None))
        if not start_str:
            continue
        summary = (getattr(event, "summary", None) or "").strip()
        description = (getattr(event, "description", None) or "").strip()
        location = (getattr(event, "location", None) or "").strip()
        uid = (getattr(event, "uid", None) or f"{summary}-{start_str}").strip()
        is_birthday = 1 if matcher.search(summary) else 0
        person = person_from_summary(summary) if is_birthday else ""
        person_slug = slugify(person) if person else ""

        sql_exec(
            upsert.format(
                uid=sqlq(uid),
                summary=sqlq(summary),
                description=sqlq(description),
                location=sqlq(location),
                start_time=sqlq(start_str),
                end_time=sqlq(end_str or ""),
                is_all_day=is_all_day,
                person=sqlq(person),
                is_birthday=is_birthday,
                updated_at=sqlq(now_iso),
            )
        )

        payload = {
            "uid": uid,
            "summary": summary,
            "description": description,
            "location": location,
            "start_time": start_str,
            "end_time": end_str,
            "is_all_day": bool(is_all_day),
            "person": person,
            "person_slug": person_slug,
            "is_birthday": bool(is_birthday),
        }
        unifier("put", f"gifts/events/{slugify(uid)}", json.dumps(payload))
        synced += 1

        if is_birthday and person_slug:
            start_aware = as_aware(event.start)
            upcoming.append(
                {
                    "uid": uid,
                    "person": person,
                    "person_slug": person_slug,
                    "summary": summary,
                    "start_time": start_str,
                    "days_until": max(0, (start_aware.date() - now.date()).days),
                }
            )

    # Dedupe by person_slug (nearest occurrence wins).
    upcoming.sort(key=lambda r: (r["days_until"], r["person_slug"]))
    seen: set[str] = set()
    queued = 0
    for row in upcoming:
        slug = row["person_slug"]
        if slug in seen:
            continue
        seen.add(slug)
        unifier("put", f"gifts/upcoming/{slug}", json.dumps(row))
        msg = json.dumps(
            {
                "person_slug": slug,
                "person": row["person"],
                "uid": row["uid"],
                "start_time": row["start_time"],
                "days_until": row["days_until"],
            },
            separators=(",", ":"),
        )
        unifier("message", "--from", "gift-sync", "gift-curator", msg)
        queued += 1
        timeline_append("gifts", f"sync queued {slug} (in {row['days_until']}d)")
        print(
            f"gift-sync: queued {row['person']} "
            f"(in {row['days_until']}d, {row['start_time']})"
        )

    unifier(
        "put",
        "gifts/sync/last",
        json.dumps(
            {
                "at": now_iso,
                "synced": synced,
                "queued": queued,
                "horizon_days": horizon_days,
            }
        ),
    )
    span_note(span, f"synced={synced} queued={queued}")
    timeline_append("gifts", f"sync done synced={synced} queued={queued}")
    status_touch("gifts", f"sync synced={synced} queued={queued}")
    print(f"gift-sync: upserted {synced} event(s), queued {queued} birthday(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
