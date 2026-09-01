"""YAML configuration loading and profile validation."""

from pathlib import Path
from typing import Any

import yaml


def load_config(config_path: str | Path) -> dict[str, Any]:
    """Load and return the YAML configuration."""
    path = Path(config_path)
    with path.open() as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Config file {path} must contain a YAML mapping.")
    return data


def get_profile(config: dict[str, Any], target: str) -> dict[str, Any]:
    """Return the backup profile for the given target (hourly or monthly)."""
    profile_key = f"{target}_backup"
    profile = config.get(profile_key)
    if not profile:
        raise ValueError(f"Profile '{profile_key}' not found in config.")
    return profile


def validate_profile(profile: dict[str, Any]) -> tuple[str, str, str]:
    """Validate required profile fields and return (repo, encrypted_password, source)."""
    repo = profile.get("repository")
    encrypted_password = profile.get("encrypted_password")
    source = profile.get("source_dir")

    if not all([repo, encrypted_password, source]):
        raise ValueError(
            "repository, encrypted_password, and source_dir must be defined in the profile."
        )
    return repo, encrypted_password, source
