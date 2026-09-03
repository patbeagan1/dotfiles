#!/usr/bin/env python3
"""Fetch a page, diff it against the last snapshot, store the diff in unifier."""

from __future__ import annotations

import argparse
import ssl
import sys
import urllib.request
from difflib import unified_diff
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import (
    cap_value,
    html_to_text,
    page_title,
    register_slug,
    sha256_hex,
    summarize_diff,
    unifier_get,
    unifier_put,
    utc_now,
    validate_slug,
    watch_prefix,
)

USER_AGENT = (
    "Mozilla/5.0 (compatible; jan-agents-watch/1.0; "
    "+https://github.com/patbeagan1/dotfiles)"
)
FETCH_TIMEOUT_S = 30


def fetch(url: str) -> str:
    if not url.startswith("https://"):
        raise ValueError(f"refusing non-https url: {url}")
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml,application/xml,text/plain;q=0.9,*/*;q=0.8",
            "Accept-Encoding": "identity",
        },
    )
    context = ssl.create_default_context()
    with urllib.request.urlopen(req, timeout=FETCH_TIMEOUT_S, context=context) as resp:
        raw = resp.read()
        charset = resp.headers.get_content_charset() or "utf-8"
    return raw.decode(charset, errors="replace")


def store_diff(slug: str, previous: str, current: str, now: str) -> str:
    diff = "\n".join(
        unified_diff(
            previous.splitlines(),
            current.splitlines(),
            fromfile=f"{slug}@previous",
            tofile=f"{slug}@{now}",
            lineterm="",
            n=2,
        )
    )
    if not diff.strip():
        digest = sha256_hex(current)
        prev_digest = sha256_hex(previous)
        diff = (
            f"(normalized text prefix unchanged; full-page hash {prev_digest[:16]} "
            f"→ {digest[:16]})"
        )
    return diff


def run(slug: str, url: str) -> int:
    slug = validate_slug(slug)
    prefix = watch_prefix(slug)
    now = utc_now()
    unifier_put(f"{prefix}/url", url)
    unifier_put(f"{prefix}/fetched_at", now)
    register_slug(slug)

    try:
        raw = fetch(url)
    except Exception as exc:
        unifier_put(f"{prefix}/status", "error")
        unifier_put(f"{prefix}/error", f"{now}  {exc}")
        print(f"watch {slug}: fetch failed: {exc}", file=sys.stderr)
        return 0

    text = html_to_text(raw)
    stored = cap_value(text)
    digest = sha256_hex(text)
    title = page_title(raw)
    if title:
        unifier_put(f"{prefix}/title", title)

    previous = unifier_get(f"{prefix}/snapshot")
    previous_hash = unifier_get(f"{prefix}/hash")

    unifier_put(f"{prefix}/hash", digest)
    unifier_put(f"{prefix}/snapshot", stored)

    if previous is None:
        unifier_put(f"{prefix}/diff", "(initial snapshot; no previous fetch)")
        unifier_put(f"{prefix}/status", "initial")
        print(f"watch {slug}: initial snapshot ({digest[:16]})")
        return 0

    if previous_hash == digest or previous == stored:
        unifier_put(f"{prefix}/status", "unchanged")
        unifier_put(f"{prefix}/error", "")
        print(f"watch {slug}: no change ({digest[:16]})")
        return 0

    diff = store_diff(slug, previous, stored, now)
    summary = summarize_diff(diff)
    history = unifier_get(f"{prefix}/history") or ""
    line = f"{now}  {summary}"
    hist_lines = ([ln for ln in history.splitlines() if ln] + [line])[-50:]

    unifier_put(f"{prefix}/diff", diff)
    unifier_put(f"{prefix}/status", "changed")
    unifier_put(f"{prefix}/changed_at", now)
    unifier_put(f"{prefix}/error", "")
    unifier_put(f"{prefix}/history", "\n".join(hist_lines))
    print(f"watch {slug}: changed ({digest[:16]})  {summary}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--slug", required=True, help="unifier key segment")
    parser.add_argument("--url", required=True, help="https URL to fetch")
    args = parser.parse_args()
    return run(args.slug, args.url)


if __name__ == "__main__":
    raise SystemExit(main())
