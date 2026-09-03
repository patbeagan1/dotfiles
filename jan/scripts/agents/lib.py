"""Unifier helpers for jan-cron website watchers and the status reporter."""

from __future__ import annotations

import hashlib
import html as html_lib
import re
import shutil
import subprocess
from datetime import datetime, timezone

INDEX_KEY = "agents/watch/index"
STATUS_PREFIX = "agents/status"
MAX_VALUE = 48_000
SLUG_RE = re.compile(r"^[a-z0-9][a-z0-9-]{0,62}$")
_BLOCK_CLOSE = re.compile(
    r"</(?:p|div|tr|li|ul|ol|h[1-6]|section|article|header|footer|nav|table|pre|blockquote|title)>",
    re.I,
)
_SCRIPT_STYLE = re.compile(r"(?is)<(script|style|noscript)[^>]*>.*?</\1>")
_COMMENT = re.compile(r"(?is)<!--.*?-->")
_BR = re.compile(r"(?i)<br\s*/?>")
_TAG = re.compile(r"<[^>]+>")


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def watch_prefix(slug: str) -> str:
    return f"agents/watch/{slug}"


def validate_slug(slug: str) -> str:
    if not SLUG_RE.match(slug):
        raise SystemExit(f"invalid slug {slug!r} (use lowercase letters, digits, hyphens)")
    return slug


def unifier_bin() -> str:
    exe = shutil.which("unifier")
    if not exe:
        raise SystemExit("unifier not found on PATH")
    return exe


def cap_value(value: str) -> str:
    if len(value) <= MAX_VALUE:
        return value
    return value[:MAX_VALUE] + "\n… [truncated]\n"


def unifier_put(key: str, value: str) -> None:
    value = cap_value(value)
    subprocess.run(
        [unifier_bin(), "put", "--", key, value],
        check=True,
        text=True,
        encoding="utf-8",
    )


def unifier_get(key: str) -> str | None:
    proc = subprocess.run(
        [unifier_bin(), "get", "--", key],
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if proc.returncode != 0:
        return None
    return proc.stdout.removesuffix("\n")


def register_slug(slug: str) -> None:
    raw = unifier_get(INDEX_KEY) or ""
    slugs = [s for s in raw.split() if s]
    if slug not in slugs:
        slugs.append(slug)
        unifier_put(INDEX_KEY, "\n".join(slugs))


def listed_slugs() -> list[str]:
    raw = unifier_get(INDEX_KEY) or ""
    return [s for s in raw.split() if s]


def sha256_hex(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def html_to_text(raw: str) -> str:
    if "<" not in raw:
        lines = [re.sub(r"[ \t]+", " ", ln).strip() for ln in raw.splitlines()]
        return "\n".join(ln for ln in lines if ln)
    raw = _SCRIPT_STYLE.sub(" ", raw)
    raw = _COMMENT.sub(" ", raw)
    raw = _BR.sub("\n", raw)
    raw = _BLOCK_CLOSE.sub("\n", raw)
    raw = _TAG.sub(" ", raw)
    raw = html_lib.unescape(raw)
    lines = [re.sub(r"[ \t]+", " ", ln).strip() for ln in raw.splitlines()]
    return "\n".join(ln for ln in lines if ln)


def page_title(raw: str) -> str:
    match = re.search(r"(?is)<title[^>]*>(.*?)</title>", raw)
    if not match:
        return ""
    return re.sub(r"\s+", " ", html_lib.unescape(_TAG.sub(" ", match.group(1)))).strip()[:200]


def summarize_diff(diff: str) -> str:
    added = 0
    removed = 0
    first = ""
    for line in diff.splitlines():
        if line.startswith("+++") or line.startswith("---") or line.startswith("@@"):
            continue
        if line.startswith("+"):
            added += 1
            if not first:
                first = line[1:].strip()
        elif line.startswith("-"):
            removed += 1
    hint = first[:80] if first else "(content changed)"
    return f"+{added} -{removed}  {hint}"
