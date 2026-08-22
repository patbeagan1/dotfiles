# Deprecated stub: host tool checklist now lives in the jan tree
# (`config.deps` / `jan config deps`). Prefer that after `jan use`.
# Kept so older install paths and muscle memory still work.

libbeagan_dependencies() {
    if command -v jan >/dev/null 2>&1; then
        command jan --no-log config deps "$@"
        return $?
    fi
    echo "jan not on PATH; install jan-cli, then: jan use \"\${LIBBEAGAN_HOME:-.}/jan\" && jan config deps" >&2
    return 1
}

echo "check dependencies with 'libbeagan_dependencies' (or: jan config deps)"
