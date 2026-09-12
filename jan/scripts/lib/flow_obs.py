"""Shared Unifier span + timeline helpers for jan multi-agent flows."""

from __future__ import annotations

import subprocess
from datetime import datetime, timezone

TIMELINE_CAP = 200


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


def unifier(*args: str, check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["unifier", *args],
        check=check,
        text=True,
        encoding="utf-8",
        capture_output=True,
    )


def span_start(name: str, **fields: str) -> str:
    args = ["log", "start", name]
    for k, v in fields.items():
        args.extend(["-f", f"{k}={v}"])
    proc = unifier(*args)
    if proc.returncode != 0:
        return ""
    return (proc.stdout or "").strip()


def span_note(span: str, message: str) -> None:
    if not span:
        return
    unifier("log", "event", span, message)


def span_end(span: str) -> None:
    if not span:
        return
    unifier("log", "end", span)


def timeline_append(prefix: str, line: str, cap: int = TIMELINE_CAP) -> None:
    key = f"{prefix}/status/timeline"
    ts = utc_now_iso()
    entry = f"{ts}  {line}"
    prev = unifier("get", key)
    prev_text = (prev.stdout or "").rstrip() if prev.returncode == 0 else ""
    if prev_text:
        next_text = f"{prev_text}\n{entry}"
    else:
        next_text = entry
    lines = next_text.splitlines()
    if len(lines) > cap:
        next_text = "\n".join(lines[-cap:])
    unifier("put", key, next_text)
    unifier("put", f"{prefix}/status/updated_at", ts)


def status_touch(prefix: str, summary: str) -> None:
    ts = utc_now_iso()
    unifier("put", f"{prefix}/status/summary", summary)
    unifier("put", f"{prefix}/status/updated_at", ts)
