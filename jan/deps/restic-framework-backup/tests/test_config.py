"""Tests for configuration loading and validation."""

import textwrap
from pathlib import Path

import pytest

from app.config import get_profile, load_config, validate_profile


def test_load_config(tmp_path: Path):
    config_file = tmp_path / "config.yaml"
    config_file.write_text(
        textwrap.dedent("""\
        global:
          restic_path: /usr/bin/restic
        hourly_backup:
          repository: /tmp/repo
          source_dir: /tmp/src
          encrypted_password: abc
    """)
    )
    config = load_config(config_file)
    assert config["global"]["restic_path"] == "/usr/bin/restic"


def test_get_profile_hourly():
    config = {"hourly_backup": {"repository": "/tmp/repo"}}
    profile = get_profile(config, "hourly")
    assert profile["repository"] == "/tmp/repo"


def test_get_profile_missing():
    with pytest.raises(ValueError, match="monthly_backup"):
        get_profile({}, "monthly")


def test_validate_profile_success():
    profile = {
        "repository": "/tmp/repo",
        "encrypted_password": "enc",
        "source_dir": "/tmp/src",
    }
    repo, enc, src = validate_profile(profile)
    assert repo == "/tmp/repo"
    assert enc == "enc"
    assert src == "/tmp/src"


def test_validate_profile_missing_fields():
    with pytest.raises(ValueError, match="must be defined"):
        validate_profile({"repository": "/tmp/repo"})
