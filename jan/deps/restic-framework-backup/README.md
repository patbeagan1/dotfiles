# restic-framework-backup

Encrypted wrapper for [Restic](https://restic.net/) backups with YAML configuration, ignore rules, and dry-run estimation.

## Setup

```bash
cd restic-framework-backup
uv venv
uv pip install -e ".[dev]"
cp config.yaml.example config.yaml
```

Generate an encrypted repository password:

```bash
uv run restic-framework-backup --encrypt
```

Paste the output into `config.yaml` under `encrypted_password`.

Initialize the repository:

```bash
uv run restic-framework-backup --config config.yaml --target hourly --init
```

## Usage

Estimate files before backing up:

```bash
uv run restic-framework-backup --config config.yaml --target hourly --estimate
```

Run a backup:

```bash
uv run restic-framework-backup --config config.yaml --target hourly
```

Or via monorepo scripts:

```bash
m run restic-framework-backup estimate
m run restic-framework-backup backup
```

## Configuration

See `config.yaml.example` for the full schema. Key sections:

- `global.restic_path` — path to the restic binary
- `ignore` — patterns excluded from backup (build artifacts, `node_modules`, etc.)
- `hourly_backup` / `monthly_backup` — repository, source, password, retention policy

The master encryption key is stored at `~/.restic.key` (mode 600).
