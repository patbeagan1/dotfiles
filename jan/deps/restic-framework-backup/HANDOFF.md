# Handoff: restic-framework-backup

## What was done

The `restic-framework-backup` project was converted from a single standalone Python script into a standard Incubator monorepo Python project using **uv**, with new ignore-rule support and pre-backup estimation. A first backup of `/home/patrick/Documents` was created on the 1TB external drive.

## Project structure

```
restic-framework-backup/
├── app/
│   ├── cli.py       # CLI entry point (--encrypt, --setup, --init, --estimate, backup)
│   ├── config.py    # YAML config loading and profile validation
│   ├── crypto.py    # Fernet encryption for restic passwords (~/.restic.key)
│   ├── ignore.py    # Default + config ignore patterns → restic --exclude args
│   └── restic.py    # restic subprocess wrapper
├── tests/           # 11 pytest tests (config + ignore)
├── config.yaml.example
├── config.yaml      # local config (gitignored)
├── project.meta.yaml
├── pyproject.toml
├── requirements.txt
├── Makefile
└── README.md
```

## Key features added

| Feature | Description |
|---|---|
| `ignore` config section | Excludes build artifacts, dependency dirs (`node_modules`, `.venv`, `target`, etc.) via restic `--exclude` |
| `--estimate` | Dry-run backup; reports file counts and data size before transferring |
| `--setup` | Creates `config.yaml` from example with a generated encrypted password |
| `--init` | Initializes the restic repository for a profile |
| `--encrypt` | Interactive helper to encrypt a password for manual config editing |

## Monorepo integration

Registered as a standard Python project. Common commands:

```bash
m run restic-framework-backup install
m run restic-framework-backup test
m run restic-framework-backup setup
m run restic-framework-backup init
m run restic-framework-backup estimate
m run restic-framework-backup backup
```

## First backup (completed 2026-07-08)

| Setting | Value |
|---|---|
| Source | `/home/patrick/Documents` |
| Repository | `/run/media/patrick/1TB/restic-documents` |
| Profile | `hourly_backup` |
| Files backed up | 21,742 |
| Data transferred | ~1.2 GB |
| Snapshot ID | `962c696f` |
| Retention | 24 hourly, 7 daily |

Dry-run estimate matched the actual backup (21,742 files, 1.2 GB).

## Configuration notes

- **`config.yaml`** is gitignored and holds the encrypted repository password.
- **`~/.restic.key`** (mode 600) is the master key used to decrypt passwords in config. Do not lose it.
- **`config.yaml.bak`** is a backup of the previous config (pointed at `/media/user/backup_disk/restic_hourly`). Safe to delete once confirmed.
- Copy `config.yaml.example` or run `--setup` on a fresh machine.

## Ignore patterns (32 defaults)

Applied automatically when `ignore.use_defaults: true` (the default):

`node_modules`, `.git`, `__pycache__`, `.venv`, `venv`, `site-packages`, `build`, `dist`, `target`, `.gradle`, `.mypy_cache`, `.pytest_cache`, `.tox`, `.eggs`, `.next`, `.nuxt`, `.parcel-cache`, `coverage`, `.turbo`, `.cache`, `vendor`, `bower_components`, `.idea`, `.terraform`, `*.pyc`, `*.pyo`, `*.class`, `*.jar`, `*.o`, `*.a`, `.DS_Store`, `.rs.bk`

Additional patterns can be added under `ignore.patterns` in config.

## Risks / follow-ups

- **Disk space**: `/run/media/patrick/1TB` was ~98% full (~20 GB free) at time of backup. Monitor space as snapshots accumulate.
- **Password recovery**: Repository password is auto-generated in `config.yaml` (encrypted). Losing both `config.yaml` and `~/.restic.key` means data is unrecoverable.
- **Monthly profile**: `monthly_backup` is configured in the example but shares the same repository; adjust if separate repos are desired.

## Validation status

- `uv run pytest` — 11/11 passed
- `m show restic-framework-backup` — project recognized by monorepo
- `restic snapshots` — 1 snapshot confirmed in repository
