#!/usr/bin/env python3
"""POC sender: drop a unifier mailbox message every second (jan cron)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import unifier_bin, unifier_get, unifier_put, utc_now

FROM = "ping-agent"
TO = "pong-agent"
SEQ_KEY = "agents/ping-agent/seq"
LAST_KEY = "agents/ping-agent/last_id"


def main() -> int:
    seq = int(unifier_get(SEQ_KEY) or "0") + 1
    now = utc_now()
    payload = {
        "hello": "from ping-agent",
        "seq": seq,
        "at": now,
    }
    proc = subprocess.run(
        [
            unifier_bin(),
            "message",
            "--from",
            FROM,
            TO,
            json.dumps(payload, separators=(",", ":")),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        check=False,
    )
    if proc.returncode != 0:
        print(
            f"ping-agent: unifier message failed: {proc.stderr.strip() or proc.stdout.strip()}",
            file=sys.stderr,
        )
        return 1
    msg_id = proc.stdout.strip()
    unifier_put(SEQ_KEY, str(seq))
    unifier_put(LAST_KEY, msg_id)
    print(f"ping-agent: sent seq={seq} id={msg_id} → {TO}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
