#!/usr/bin/env python3
"""Collect gifts pipeline observability: health, wakeups, per-person board, timeline.

Usage:
  python3 status.py           # human text
  python3 status.py --json    # machine JSON
  python3 status.py --html    # self-contained HTML (for board)
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from html import escape
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
try:
    from flow_obs import status_touch, unifier  # type: ignore
except ImportError:
    def unifier(*args: str, check: bool = False):  # type: ignore
        return subprocess.run(
            ["unifier", *args], check=check, text=True, encoding="utf-8", capture_output=True
        )

    def status_touch(prefix: str, summary: str) -> None:  # type: ignore
        pass


MIN_SIGNAL_DEFAULT = 55


def u_get(key: str) -> str:
    proc = unifier("get", key)
    if proc.returncode != 0:
        return ""
    return (proc.stdout or "").strip()


def u_list_mail(prefix: str) -> list[str]:
    """List mailbox/message files (unifier list is mail-only)."""
    proc = unifier("list", prefix)
    if proc.returncode != 0:
        return []
    return [ln.strip() for ln in (proc.stdout or "").splitlines() if ln.strip()]


def unifier_home() -> Path:
    env = (os.environ.get("UNIFIER_HOME") or "").strip()
    if env:
        return Path(env)
    return Path.home() / ".local" / "unifier"


def key_slugs(rel_prefix: str) -> list[str]:
    """List key basenames under keys/<rel_prefix>/ on disk.

    Hot daemon may keep keys in RAM — flush first so the board sees them.
    """
    unifier("daemon", "flush")
    root = unifier_home() / "keys" / rel_prefix
    if not root.is_dir():
        return []
    out: list[str] = []
    for p in sorted(root.iterdir()):
        if p.is_file():
            out.append(p.name.removesuffix(".txt"))
    return out


def sql_people(table: str) -> list[str]:
    proc = unifier("sql", "exec", "gifts", f"SELECT person FROM {table}")
    if proc.returncode != 0:
        return []
    lines = [ln.strip() for ln in (proc.stdout or "").splitlines() if ln.strip()]
    # first line is often the column header
    people: list[str] = []
    for ln in lines:
        if ln.lower() == "person":
            continue
        people.append(ln)
    return people


def sql_count(table: str, where: str = "") -> int:
    q = f"SELECT COUNT(*) FROM {table}"
    if where:
        q += f" WHERE {where}"
    proc = unifier("sql", "exec", "gifts", q)
    if proc.returncode != 0:
        return 0
    lines = [ln.strip() for ln in (proc.stdout or "").splitlines() if ln.strip()]
    if len(lines) < 2:
        return 0
    try:
        return int(lines[-1])
    except ValueError:
        return 0


def mailbox_pending(leaf: str) -> int:
    return sum(1 for ln in u_list_mail(f"mailbox/{leaf}") if ln.startswith("{"))


def jan_cron(*args: str) -> str:
    env = os.environ.copy()
    proc = subprocess.run(
        ["jan", "--no-log", "cron", *args],
        check=False,
        text=True,
        encoding="utf-8",
        capture_output=True,
        env=env,
    )
    return ((proc.stdout or "") + (proc.stderr or "")).strip()


def cron_compact() -> str:
    out = jan_cron("status", "--compact")
    for line in out.splitlines():
        if "jan cron daemon" in line or line.startswith("ok "):
            return line
    return out.splitlines()[0] if out else "(jan cron unavailable)"


def cron_list_lines() -> list[str]:
    out = jan_cron("--list")
    return [ln for ln in out.splitlines() if "|" in ln]


def gift_cron_next() -> dict[str, str]:
    wanted = {"gift-sync": "(unknown)", "gift-digest": "(unknown)"}
    for ln in cron_list_lines():
        parts = ln.split("|")
        if len(parts) < 3:
            continue
        chain, _cron, nxt = parts[0], parts[1], parts[2]
        leaf = chain.split()[-1] if chain.strip() else ""
        if leaf in wanted:
            status = parts[3] if len(parts) > 3 else ""
            wanted[leaf] = f"{nxt}" + (f" [{status}]" if status else "")
    return wanted


def load_json(key: str) -> dict | None:
    raw = u_get(key)
    if not raw:
        return None
    try:
        val = json.loads(raw)
        return val if isinstance(val, dict) else None
    except json.JSONDecodeError:
        return None


def person_rows(min_signal: int = MIN_SIGNAL_DEFAULT) -> list[dict]:
    slugs = set(key_slugs("gifts/upcoming"))
    slugs |= set(key_slugs("gifts/ideas"))
    slugs |= set(key_slugs("gifts/plans"))
    slugs |= set(sql_people("ideas"))
    slugs |= set(sql_people("plans"))
    rows: list[dict] = []
    for slug in sorted(slugs):
        upcoming = load_json(f"gifts/upcoming/{slug}") or {}
        ideas = load_json(f"gifts/ideas/{slug}")
        plan = u_get(f"gifts/plans/{slug}")
        notes = u_get(f"gifts/notes/{slug}")
        signal = None
        if ideas is not None:
            try:
                signal = int(ideas.get("signal", 0))
            except (TypeError, ValueError):
                signal = 0
        if plan:
            stage = "planned"
        elif signal is not None and signal >= min_signal:
            stage = "curated"
        elif signal is not None:
            stage = "held"
        else:
            stage = "queued"
        rows.append(
            {
                "slug": slug,
                "person": upcoming.get("person") or slug,
                "days": upcoming.get("days_until"),
                "notes": bool(notes),
                "signal": signal,
                "plan": bool(plan),
                "stage": stage,
                "start_time": upcoming.get("start_time") or "",
            }
        )
    rows.sort(key=lambda r: (r["days"] if isinstance(r["days"], int) else 9999, r["slug"]))
    return rows


def collect(min_signal: int = MIN_SIGNAL_DEFAULT) -> dict:
    rows = person_rows(min_signal)
    pending_curator = mailbox_pending("gift-curator")
    pending_planner = mailbox_pending("gift-planner")
    sync_last = u_get("gifts/sync/last") or "(none yet)"
    digest_url = u_get("gifts/digest/url") or "(none yet)"
    board_url = u_get("gifts/board/url") or "(none yet)"
    timeline = u_get("gifts/status/timeline")
    try:
        probe = subprocess.run(
            ["unifier", "sql", "list"],
            check=False,
            text=True,
            capture_output=True,
        )
        unifier_ok = probe.returncode == 0
    except OSError:
        unifier_ok = False

    counts = {
        "events": sql_count("events"),
        "birthdays": sql_count("events", "is_birthday=1"),
        "ideas": sql_count("ideas"),
        "plans": sql_count("plans"),
    }
    wake = gift_cron_next()
    summary = (
        f"{len(rows)} upcoming · {counts['plans']} planned · "
        f"mail curator={pending_curator} planner={pending_planner}"
    )
    try:
        status_touch("gifts", summary)
    except Exception:
        pass

    return {
        "health": {
            "unifier": "up" if unifier_ok else "down",
            "cron": cron_compact(),
            "sync_last": sync_last,
            "pending_curator": pending_curator,
            "pending_planner": pending_planner,
            "digest_url": digest_url,
            "board_url": board_url,
            "counts": counts,
        },
        "wakeups": {
            "gift-sync": wake.get("gift-sync", "(unknown)"),
            "gift-digest": wake.get("gift-digest", "(unknown)"),
            "gift-curator": "mailbox (on mail from gift-sync)",
            "gift-planner": "mailbox (on mail from gift-curator)",
        },
        "board": rows,
        "timeline": timeline.splitlines()[-15:] if timeline else [],
        "summary": summary,
        "min_signal": min_signal,
    }


def render_text(data: dict) -> str:
    h = data["health"]
    lines = [
        "== health ==",
        f"unifier     {h['unifier']}",
        f"cron        {h['cron']}",
        f"events      {h['counts']['events']}",
        f"birthdays   {h['counts']['birthdays']}",
        f"ideas       {h['counts']['ideas']}",
        f"plans       {h['counts']['plans']}",
        f"pending     curator={h['pending_curator']}  planner={h['pending_planner']}",
        f"sync        {h['sync_last']}",
        f"digest      {h['digest_url']}",
        f"board       {h['board_url']}",
        "",
        "== wakeups ==",
    ]
    for k, v in data["wakeups"].items():
        lines.append(f"{k:<14}{v}")
    lines += ["", "== board =="]
    if not data["board"]:
        lines.append("(no upcoming birthdays)")
    else:
        lines.append(f"{'person':<22}{'days':>5}  notes  signal  plan  stage")
        for r in data["board"]:
            days = r["days"] if r["days"] is not None else "?"
            notes = "yes" if r["notes"] else "-"
            signal = str(r["signal"]) if r["signal"] is not None else "-"
            plan = "yes" if r["plan"] else "-"
            lines.append(
                f"{str(r['person'])[:22]:<22}{str(days):>5}  {notes:<5}  {signal:<6}  {plan:<4}  {r['stage']}"
            )
    lines += ["", "== timeline =="]
    if not data["timeline"]:
        lines.append("(empty)")
    else:
        lines.extend(data["timeline"])
    return "\n".join(lines) + "\n"


def render_html(data: dict) -> str:
    h = data["health"]
    rows_html = []
    for r in data["board"]:
        days = escape(str(r["days"] if r["days"] is not None else "?"))
        signal = escape(str(r["signal"] if r["signal"] is not None else "-"))
        rows_html.append(
            "<tr>"
            f"<td>{escape(str(r['person']))}</td>"
            f"<td>{days}</td>"
            f"<td>{'yes' if r['notes'] else '-'}</td>"
            f"<td>{signal}</td>"
            f"<td>{'yes' if r['plan'] else '-'}</td>"
            f"<td><code>{escape(r['stage'])}</code></td>"
            "</tr>"
        )
    if not rows_html:
        rows_html.append('<tr><td colspan="6">(no upcoming)</td></tr>')
    timeline = (
        "<br>\n".join(escape(t) for t in data["timeline"])
        if data["timeline"]
        else "(empty)"
    )
    wake_items = "".join(
        f"<li><strong>{escape(k)}</strong> — {escape(str(v))}</li>"
        for k, v in data["wakeups"].items()
    )
    digest = escape(str(h["digest_url"]))
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Gifts flow</title>
<style>
  body{{font-family:ui-sans-serif,system-ui,sans-serif;margin:1.5rem;line-height:1.45;color:#1a1a1a;background:#f7f4ef}}
  h1{{font-size:1.35rem;margin:0 0 .5rem}}
  h2{{font-size:1.05rem;margin:1.4rem 0 .5rem;border-bottom:1px solid #d9d0c4;padding-bottom:.25rem}}
  .health{{display:grid;grid-template-columns:repeat(auto-fill,minmax(14rem,1fr));gap:.5rem .75rem;font-size:.92rem}}
  .health div{{background:#fff;border:1px solid #e4dbcf;padding:.5rem .65rem}}
  .health dt{{color:#6b5c4c;font-size:.75rem;text-transform:uppercase;letter-spacing:.03em}}
  .health dd{{margin:0;word-break:break-word}}
  table{{border-collapse:collapse;width:100%;background:#fff;border:1px solid #e4dbcf}}
  th,td{{padding:.4rem .55rem;text-align:left;border-bottom:1px solid #eee6dc;font-size:.92rem}}
  th{{background:#f0ebe3;font-weight:600}}
  ul{{margin:.25rem 0;padding-left:1.2rem}}
  .timeline{{font-family:ui-monospace,monospace;font-size:.82rem;background:#fff;border:1px solid #e4dbcf;padding:.75rem;white-space:pre-wrap}}
  a{{color:#6b3f1f}}
</style>
</head>
<body>
<h1>Gifts flow</h1>
<p>{escape(data.get("summary", ""))}</p>
<h2>Health</h2>
<div class="health">
  <div><dt>Unifier</dt><dd>{escape(str(h["unifier"]))}</dd></div>
  <div><dt>Cron</dt><dd>{escape(str(h["cron"]))}</dd></div>
  <div><dt>Pending mail</dt><dd>curator={h["pending_curator"]} · planner={h["pending_planner"]}</dd></div>
  <div><dt>Counts</dt><dd>events={h["counts"]["events"]} · ideas={h["counts"]["ideas"]} · plans={h["counts"]["plans"]}</dd></div>
  <div><dt>Sync</dt><dd>{escape(str(h["sync_last"]))}</dd></div>
  <div><dt>Digest</dt><dd><a href="{digest}">{digest}</a></dd></div>
</div>
<h2>Wakeups</h2>
<ul>{wake_items}</ul>
<h2>Board</h2>
<table>
<thead><tr><th>Person</th><th>Days</th><th>Notes</th><th>Signal</th><th>Plan</th><th>Stage</th></tr></thead>
<tbody>
{"".join(rows_html)}
</tbody>
</table>
<h2>Timeline</h2>
<div class="timeline">{timeline}</div>
</body>
</html>
"""


def main() -> int:
    mode = "text"
    if "--json" in sys.argv:
        mode = "json"
    elif "--html" in sys.argv:
        mode = "html"
    data = collect()
    if mode == "json":
        print(json.dumps(data, indent=2))
    elif mode == "html":
        print(render_html(data))
    else:
        print(render_text(data), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
