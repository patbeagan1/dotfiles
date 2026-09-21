#!/usr/bin/env python3
"""Read watcher diffs from unifier and write a status report to separate keys."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import (
    INDEX_KEY,
    STATUS_PREFIX,
    listed_slugs,
    unifier_get,
    unifier_put,
    utc_now,
    watch_prefix,
)


def load_watcher(slug: str) -> dict[str, str]:
    prefix = watch_prefix(slug)
    keys = (
        "url",
        "title",
        "status",
        "fetched_at",
        "changed_at",
        "hash",
        "error",
        "history",
        "diff",
    )
    data = {"slug": slug}
    for name in keys:
        value = unifier_get(f"{prefix}/{name}")
        if value:
            data[name] = value
    return data


def timeline_entries(watchers: list[dict[str, str]]) -> list[str]:
    rows: list[tuple[str, str]] = []
    for watcher in watchers:
        slug = watcher["slug"]
        for line in watcher.get("history", "").splitlines():
            line = line.strip()
            if not line:
                continue
            rows.append((line[:20], f"{line}  [{slug}]"))
        if watcher.get("status") == "initial" and watcher.get("fetched_at"):
            ts = watcher["fetched_at"]
            rows.append((ts, f"{ts}  initial snapshot  [{slug}]"))
        if watcher.get("status") == "error" and watcher.get("error"):
            err = watcher["error"]
            rows.append((err[:20], f"{err}  [{slug}]"))
    rows.sort(key=lambda item: item[0], reverse=True)
    return [text for _, text in rows]


def render_report(watchers: list[dict[str, str]], now: str) -> tuple[str, str, str]:
    changed = [w for w in watchers if w.get("status") == "changed"]
    errors = [w for w in watchers if w.get("status") == "error"]
    summary = (
        f"{len(watchers)} watchers · {len(changed)} changed · "
        f"{len(errors)} errors · {now}"
    )

    lines = [
        f"# agent status  {now}",
        "",
        summary,
        "",
    ]
    if not watchers:
        lines.append(f"No watchers have checked in yet (`unifier get {INDEX_KEY}` is empty).")
        lines.append("Run a watcher, or start `jan cron start`.")
        return "\n".join(lines) + "\n", summary, ""

    for watcher in watchers:
        slug = watcher["slug"]
        lines.append(f"## {slug}")
        if watcher.get("title"):
            lines.append(f"title: {watcher['title']}")
        lines.append(f"url: {watcher.get('url', '(unknown)')}")
        lines.append(f"status: {watcher.get('status', '(unknown)')}")
        lines.append(f"fetched: {watcher.get('fetched_at', '(never)')}")
        if watcher.get("changed_at"):
            lines.append(f"last change: {watcher['changed_at']}")
        if watcher.get("error"):
            lines.append(f"error: {watcher['error']}")
        history = watcher.get("history", "").strip()
        if history:
            lines.append("when:")
            for item in history.splitlines()[-8:]:
                lines.append(f"  {item}")
        diff = watcher.get("diff", "").strip()
        if diff and watcher.get("status") in {"changed", "initial"}:
            preview = "\n".join(diff.splitlines()[:24])
            lines.append("diff:")
            for diff_line in preview.splitlines():
                lines.append(f"  {diff_line}")
        lines.append("")

    report = "\n".join(lines).rstrip() + "\n"
    timeline = "\n".join(timeline_entries(watchers))
    return report, summary, timeline


def run() -> int:
    now = utc_now()
    watchers = [load_watcher(slug) for slug in listed_slugs()]
    report, summary, timeline = render_report(watchers, now)
    changed = [w["slug"] for w in watchers if w.get("status") == "changed"]

    unifier_put(f"{STATUS_PREFIX}/report", report)
    unifier_put(f"{STATUS_PREFIX}/summary", summary)
    unifier_put(f"{STATUS_PREFIX}/timeline", timeline)
    unifier_put(f"{STATUS_PREFIX}/updated_at", now)
    unifier_put(f"{STATUS_PREFIX}/changed", " ".join(changed))

    print(summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
