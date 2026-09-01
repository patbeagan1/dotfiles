"""Tests for ignore pattern handling."""

from app.ignore import (
    DEFAULT_IGNORE_PATTERNS,
    build_exclude_args,
    get_ignore_patterns,
)


def test_defaults_include_node_modules():
    patterns = get_ignore_patterns({})
    assert "node_modules" in patterns
    assert ".git" in patterns
    assert "__pycache__" in patterns


def test_use_defaults_false():
    config = {
        "ignore": {
            "use_defaults": False,
            "patterns": ["custom-dir"],
        }
    }
    patterns = get_ignore_patterns(config)
    assert patterns == ["custom-dir"]
    assert "node_modules" not in patterns


def test_custom_patterns_merged_with_defaults():
    config = {
        "ignore": {
            "use_defaults": True,
            "patterns": ["my-custom-artifact"],
        }
    }
    patterns = get_ignore_patterns(config)
    assert "node_modules" in patterns
    assert "my-custom-artifact" in patterns


def test_no_duplicate_patterns():
    config = {
        "ignore": {
            "use_defaults": True,
            "patterns": ["node_modules"],
        }
    }
    patterns = get_ignore_patterns(config)
    assert patterns.count("node_modules") == 1


def test_build_exclude_args():
    config = {"ignore": {"use_defaults": False, "patterns": ["foo"]}}
    args = build_exclude_args(config)
    assert args == ["--exclude-caches", "--exclude", "foo"]


def test_default_patterns_not_empty():
    assert len(DEFAULT_IGNORE_PATTERNS) > 10
