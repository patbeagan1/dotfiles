#!/usr/bin/env python3
"""POC receiver: woken by jan on unifier mailbox notice; load message by id."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import unifier_bin, unifier_get, unifier_put, utc_now

TO = "pong-agent"
LAST_KEY = "agents/pong-agent/last"
COUNT_KEY = "agents/pong-agent/count"


def fetch_envelope(message_id: str) -> dict:
    """Load mailbox/<to>/<id>.txt via the unifier daemon (list)."""
    proc = subprocess.run(
        [unifier_bin(), "list", "--", f"mailbox/{TO}"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        check=False,
    )
    if proc.returncode != 0:
        raise SystemExit(
            f"pong-agent: unifier list failed: {proc.stderr.strip() or proc.stdout.strip()}"
        )
    for block in proc.stdout.split("---\n"):
        lines = [ln for ln in block.strip().splitlines() if ln]
        if not lines:
            continue
        head = lines[0].split()
        if not head:
            continue
        if head[0] == message_id:
            body = "\n".join(lines[1:])
            try:
                return json.loads(body)
            except json.JSONDecodeError as exc:
                raise SystemExit(f"pong-agent: bad envelope JSON: {exc}") from exc
    raise SystemExit(f"pong-agent: message not found in mailbox/{TO}: {message_id}")


def ack(message_id: str) -> None:
    subprocess.run(
        [unifier_bin(), "ack", "--", message_id],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--message-id",
        default=os.environ.get("JAN_UNIFIER_MESSAGE_ID", ""),
        help="Unifier mailbox UUID (also read from JAN_UNIFIER_MESSAGE_ID)",
    )
    args = parser.parse_args()
    message_id = (args.message_id or "").strip()
    if not message_id:
        print(
            "pong-agent: missing --message-id / JAN_UNIFIER_MESSAGE_ID "
            "(jan passes this on event wakeup)",
            file=sys.stderr,
        )
        return 2

    env_from = os.environ.get("JAN_UNIFIER_FROM", "")
    env_to = os.environ.get("JAN_UNIFIER_TO", TO)
    envelope = fetch_envelope(message_id)
    payload = envelope.get("payload", envelope)
    now = utc_now()
    record = {
        "received_at": now,
        "message_id": message_id,
        "from": envelope.get("from", env_from),
        "to": envelope.get("to", env_to),
        "payload": payload,
    }
    unifier_put(LAST_KEY, json.dumps(record, indent=2))
    count = int(unifier_get(COUNT_KEY) or "0") + 1
    unifier_put(COUNT_KEY, str(count))
    ack(message_id)
    print(
        f"pong-agent: got #{count} id={message_id} "
        f"from={record['from']} payload={json.dumps(payload, separators=(',', ':'))}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
