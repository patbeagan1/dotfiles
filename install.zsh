#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

# Verbose mode - quiet by default, enable with VERBOSE=true or --verbose
VERBOSE_MODE=${VERBOSE_MODE:-false}

# Full jan refresh (re-emit aliases/config, link, apply, deps). Also enabled by --refresh.
LIBBEAGAN_REFRESH=${LIBBEAGAN_REFRESH:-false}

# Per-step timing traces (stderr). Enable with LIBBEAGAN_TRACE=1 or --trace.
LIBBEAGAN_TRACE=${LIBBEAGAN_TRACE:-false}

# Check for flags (order-independent among known flags)
for _libbeagan_arg in "$@"; do
    case "$_libbeagan_arg" in
        --verbose) VERBOSE_MODE=true ;;
        --refresh|--install) LIBBEAGAN_REFRESH=true ;;
        --trace) LIBBEAGAN_TRACE=true ;;
    esac
done
unset _libbeagan_arg

# High-resolution timing (zsh/datetime)
zmodload zsh/datetime 2>/dev/null || true
typeset -gF _LIBBEAGAN_T0
typeset -gF _LIBBEAGAN_STEP_T0
typeset -a _LIBBEAGAN_TRACE_ROWS
_LIBBEAGAN_T0=${EPOCHREALTIME:-$SECONDS}
_LIBBEAGAN_STEP_T0=$_LIBBEAGAN_T0
_LIBBEAGAN_TRACE_ROWS=()

_libbeagan_now() {
    print -r -- "${EPOCHREALTIME:-$SECONDS}"
}

_libbeagan_trace() {
    [[ "$LIBBEAGAN_TRACE" == "true" ]] || return 0
    local msg="$1"
    local now step_ms total_ms
    now="$(_libbeagan_now)"
    step_ms=$(printf '%.1f' $(( (now - _LIBBEAGAN_STEP_T0) * 1000.0 )))
    total_ms=$(printf '%.1f' $(( (now - _LIBBEAGAN_T0) * 1000.0 )))
    _LIBBEAGAN_STEP_T0=$now
    _LIBBEAGAN_TRACE_ROWS+=("${step_ms}|${total_ms}|${msg}")
    print -u2 -- "[libbeagan trace] +${step_ms}ms (Σ${total_ms}ms)  ${msg}"
}

_libbeagan_trace_summary() {
    [[ "$LIBBEAGAN_TRACE" == "true" ]] || return 0
    local total_ms
    total_ms=$(printf '%.1f' $(( ($(_libbeagan_now) - _LIBBEAGAN_T0) * 1000.0 )))
    print -u2 -- "[libbeagan trace] ── slowest steps (total ${total_ms}ms) ──"
    local row step rest total msg
    local -a ranked
    ranked=("${(@f)$(printf '%s\n' "${_LIBBEAGAN_TRACE_ROWS[@]}" | sort -t'|' -k1,1 -nr)}")
    local i=0
    for row in "${ranked[@]}"; do
        i=$((i + 1))
        [[ $i -gt 15 ]] && break
        [[ -z "$row" ]] && continue
        step="${row%%|*}"
        rest="${row#*|}"
        total="${rest%%|*}"
        msg="${rest#*|}"
        print -u2 -- "[libbeagan trace]   ${step}ms  ${msg}"
    done
}

# Function to print messages only if in verbose mode
print_info() {
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo "$@"
    fi
}

print_info "Welcome to libbeagan."
_libbeagan_trace "start (refresh=${LIBBEAGAN_REFRESH} verbose=${VERBOSE_MODE})"

# Function to safely source files
safe_source() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        source "$file"
    else
        echo "⚠️  Warning: $description not found at $file"
    fi
}

# Helper functions for sourcing
function source_libbeagan() { 
    if [[ -f "$LIBBEAGAN_HOME/$1" ]]; then
        source "$LIBBEAGAN_HOME/$1"
        return 0
    else
        echo "⚠️  Warning: Could not source $LIBBEAGAN_HOME/$1"
        return 1
    fi
}

function source_alias() { 
    source_libbeagan "aliases/$1"
}

validate_env() {
    local has_errors=false
    
    # Validate LIBBEAGAN_HOME
    if [[ ! -v LIBBEAGAN_HOME ]]; then
        echo '❌ Error: LIBBEAGAN_HOME environment variable is not set.'
        echo '   Please add the following to your ~/.zshrc file:'
        echo '   export LIBBEAGAN_HOME="$HOME/libbeagan"'
        echo
        has_errors=true
    elif [[ ! -d "$LIBBEAGAN_HOME" ]]; then
        echo "❌ Error: LIBBEAGAN_HOME directory does not exist: $LIBBEAGAN_HOME"
        echo "   Please ensure the path is correct."
        has_errors=true
    else
        print_info "✅ Using libbeagan from: $LIBBEAGAN_HOME"
    fi

    # Personal utilities are provided by jan (dotfiles/jan), not LIBBEAGAN_SCRIPTS.

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Source a jan-emitted config.zsh, timing each `# --- from \`config …\`` section when tracing.
_libbeagan_source_config_traced() {
    local emitted="$1"
    if [[ "$LIBBEAGAN_TRACE" != "true" ]]; then
        # shellcheck disable=SC1090
        source "$emitted"
        return $?
    fi

    local -a lines
    lines=("${(@f)$(<"$emitted")}")
    local chunk="" section="(preamble)"
    local line tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/libbeagan-cfg.XXXXXX")"
    for line in "${lines[@]}"; do
        if [[ "$line" == '# --- from `config '* ]]; then
            if [[ -n "$chunk" ]]; then
                print -r -- "$chunk" > "$tmp"
                # shellcheck disable=SC1090
                source "$tmp"
                _libbeagan_trace "config section: ${section}"
            fi
            section="${line#\# --- from \`}"
            section="${section%\` ---}"
            chunk=""
            continue
        fi
        chunk+="$line"$'\n'
    done
    if [[ -n "$chunk" ]]; then
        print -r -- "$chunk" > "$tmp"
        # shellcheck disable=SC1090
        source "$tmp"
        _libbeagan_trace "config section: ${section}"
    fi
    rm -f "$tmp"
}

# Source emitted jan config exactly once per shell.
load_configurations() {
    if [[ -n "${LIBBEAGAN_CONFIG_LOADED:-}" ]]; then
        print_info "📁 Jan config already loaded — skipping"
        _libbeagan_trace "load_configurations (already loaded)"
        return 0
    fi

    local emitted="${XDG_CONFIG_HOME:-$HOME/.config}/jan/config.zsh"
    if [[ -f "$emitted" ]]; then
        print_info "📁 Loading jan-emitted configuration: $emitted"
        _libbeagan_source_config_traced "$emitted"
        LIBBEAGAN_CONFIG_LOADED=1
        _libbeagan_trace "load_configurations done"
        return 0
    fi

    print_info "📁 Loading configurations (legacy configs/*.zsh; run install with jan for emit)..."
    safe_source "$LIBBEAGAN_HOME/configs/config-zsh.zsh" "ZSH configuration"
    _libbeagan_trace "legacy config-zsh"
    safe_source "$LIBBEAGAN_HOME/configs/config-omzsh.zsh" "Oh My Zsh configuration"
    _libbeagan_trace "legacy config-omzsh"
    safe_source "$LIBBEAGAN_HOME/configs/config-golang.zsh" "Go configuration"
    _libbeagan_trace "legacy config-golang"
    safe_source "$LIBBEAGAN_HOME/configs/config-android.zsh" "Android configuration"
    _libbeagan_trace "legacy config-android"
    safe_source "$LIBBEAGAN_HOME/configs/config-ios.zsh" "iOS configuration"
    _libbeagan_trace "legacy config-ios"
    safe_source "$LIBBEAGAN_HOME/configs/config-emacs.zsh" "emacs configuration"
    _libbeagan_trace "legacy config-emacs"

    local machines_dir="$LIBBEAGAN_HOME/configs/machines"
    if [[ -d "$machines_dir" ]]; then
        for machine_file in "$machines_dir"/*.zsh(N); do
            [[ -f "$machine_file" ]] || continue
            local machine_name="${machine_file:t:r}"
            safe_source "$machine_file" "$machine_name configuration"
            _libbeagan_trace "legacy machine ${machine_name}"
        done
    fi
    LIBBEAGAN_CONFIG_LOADED=1
    _libbeagan_trace "load_configurations done (legacy)"
}


# Load alias files from aliases/ by prefix (like #ifdef in C).
# Prefixes: alias_ (always) | aliasmac_ | aliaslinux_ | aliasinteractive_ | aliaslogin_ | aliasdebug_ | aliasroot_
# Set LIBBEAGAN_ALIAS_DEBUG to print each alias file as it is loaded.
_libbeagan_load_aliases() {
    local aliases_dir="$LIBBEAGAN_HOME/aliases"
    if [[ ! -d "$aliases_dir" ]]; then
        return 0
    fi
    for f in "${aliases_dir}"/*.zsh(N); do
        [[ -f "$f" ]] || continue
        local name="${f:t:r}"
        local do_load=false
        if [[ "$name" == aliasmac_* ]]; then
            command is-test system os mac &>/dev/null && do_load=true
        elif [[ "$name" == aliaslinux_* ]]; then
            command is-test system os linux &>/dev/null && do_load=true
        elif [[ "$name" == aliasinteractive_* ]]; then
            [[ -o interactive ]] && do_load=true
        elif [[ "$name" == aliaslogin_* ]]; then
            [[ -o login ]] && do_load=true
        elif [[ "$name" == aliasdebug_* ]]; then
            [[ -n "${DEBUG:-}" ]] && do_load=true
        elif [[ "$name" == aliasroot_* ]]; then
            [[ $EUID -eq 0 ]] && do_load=true
        elif [[ "$name" == alias_* ]]; then
            do_load=true
        fi
        if [[ "$do_load" == true ]]; then
            [[ -n "${LIBBEAGAN_ALIAS_DEBUG:-}" ]] && echo "[alias] $name" >&2
            safe_source "$f" "$name"
            _libbeagan_trace "legacy alias file ${name}"
        fi
    done
}

load_aliases() {
    print_info "📝 Loading aliases..."

    # Jan-generated aliases (once). Prefer bytecode (.zwc) when present — zsh
    # loads it automatically if newer than the .zsh source.
    local jan_aliases="${XDG_CONFIG_HOME:-$HOME/.config}/jan/scripts/aliases.zsh"
    if [[ -z "${LIBBEAGAN_JAN_ALIASES_LOADED:-}" && -f "$jan_aliases" ]]; then
        _libbeagan_ensure_alias_zwc "$jan_aliases"
        _libbeagan_trace "aliases: ensure zwc"
        # shellcheck disable=SC1090
        source "$jan_aliases"
        LIBBEAGAN_JAN_ALIASES_LOADED=1
        _libbeagan_trace "aliases: source jan aliases.zsh"
    fi

    safe_source "$LIBBEAGAN_HOME/alias" "Main alias file"
    _libbeagan_trace "aliases: source \$LIBBEAGAN_HOME/alias"
    _libbeagan_load_aliases
    _libbeagan_trace "aliases: done"
}

# Compile jan aliases.zsh → aliases.zsh.zwc when missing or stale (fast; no jan spawn).
_libbeagan_ensure_alias_zwc() {
    local src="$1"
    local zwc="${src}.zwc"
    [[ -f "$src" ]] || return 0
    if [[ -f "$zwc" && ! "$src" -nt "$zwc" ]]; then
        return 0
    fi
    if ! zcompile -U "$src" 2>/dev/null; then
        print_info "   (zcompile aliases skipped — sourcing plain .zsh)"
        return 0
    fi
    print_info "   Cached jan aliases bytecode: $zwc"
}

setup_completions() {
    print_info "🔧 Setting up Zsh completions..."

    local completions_dir="$LIBBEAGAN_HOME/completions"
    local need_compinit=false

    # Add main completions directory
    if [[ -d "$completions_dir" ]]; then
        if [[ ! "$fpath" =~ "$completions_dir" ]]; then
            fpath=("$completions_dir" $fpath)
            print_info "✅ Added main completions directory to fpath"
            need_compinit=true
        else
            print_info "✅ Main completions directory already in fpath"
        fi
    else
        echo "⚠️  Warning: Main completions directory not found: $completions_dir"
    fi
    _libbeagan_trace "completions: fpath setup"

    # Initialize completions if needed
    if [[ "$need_compinit" == "true" ]]; then
        if command -v compinit >/dev/null 2>&1; then
            autoload -Uz compinit && compinit
            print_info "✅ Initialized Zsh completions"
            _libbeagan_trace "completions: compinit"
        fi
    fi
    _libbeagan_trace "completions: done"
}

# Prefer jan tree + (optionally) regenerate alias/config artifacts.
# Heavy work runs only when LIBBEAGAN_REFRESH=true or outputs are missing.
setup_scripts() {
    print_info "🔧 Setting up scripts / jan utilities..."
    export PATH=$PATH:$LIBBEAGAN_HOME/bin:$LIBBEAGAN_HOME/bin_local
    print_info "   PATH prepended with: $LIBBEAGAN_HOME/bin and $LIBBEAGAN_HOME/bin_local"
    _libbeagan_trace "setup_scripts: PATH"

    local jan_dir="${LIBBEAGAN_HOME}/jan"
    print_info "   Looking for jan tree at: $jan_dir"

    if [[ ! -d "$jan_dir" ]]; then
        print_info "ℹ️  No jan tree at $jan_dir — skipping jan prefer / alias setup"
        print_info "   Sync or copy dotfiles/jan there to enable personal utilities via jan"
        _libbeagan_trace "setup_scripts: no jan tree"
        return 0
    fi
    print_info "✅ Found jan tree: $jan_dir"

    if ! command -v jan >/dev/null 2>&1; then
        print_info "ℹ️  jan binary not on PATH — tree is present but not activated"
        print_info "   Install jan-cli, then re-run install or: jan use \"$jan_dir\""
        _libbeagan_trace "setup_scripts: jan missing"
        return 0
    fi
    print_info "   jan binary: $(command -v jan)"

    local alias_out="${XDG_CONFIG_HOME:-$HOME/.config}/jan/scripts/aliases.zsh"
    local config_out="${XDG_CONFIG_HOME:-$HOME/.config}/jan/config.zsh"
    local need_refresh=false
    if [[ "$LIBBEAGAN_REFRESH" == "true" ]]; then
        need_refresh=true
    elif [[ ! -f "$alias_out" || ! -f "$config_out" ]]; then
        need_refresh=true
        print_info "   Emitted jan files missing — running a one-time refresh"
    fi

    if [[ "$need_refresh" != "true" ]]; then
        print_info "   Using existing jan emit/aliases (run \`refresh\` or set LIBBEAGAN_REFRESH=1 to regenerate)"
        _libbeagan_trace "setup_scripts: fast path (cached emit)"
        return 0
    fi

    print_info "   Running: jan use \"$jan_dir\" --root scripts.spec.yaml"
    if jan use "$jan_dir" --root scripts.spec.yaml; then
        print_info "✅ Preferred jan directory saved"
        if command -v jan >/dev/null 2>&1; then
            local show_out
            show_out="$(jan use --show 2>/dev/null || true)"
            if [[ -n "$show_out" ]]; then
                print_info "   jan use --show:"
                while IFS= read -r line; do
                    print_info "     $line"
                done <<< "$show_out"
            fi
        fi
    else
        echo "⚠️  Warning: jan use failed for $jan_dir (continuing)"
    fi
    _libbeagan_trace "setup_scripts: jan use"

    print_info "   Writing shell aliases to: $alias_out"
    mkdir -p "$(dirname "$alias_out")"
    if jan --no-log alias --shell zsh -o "$alias_out"; then
        local alias_count
        alias_count="$(grep -c '^alias ' "$alias_out" 2>/dev/null || echo 0)"
        print_info "✅ Generated $alias_count alias(es) in $alias_out"
        # Drop stale bytecode then rebuild so the next (and this) source is cheap
        rm -f "${alias_out}.zwc"
        _libbeagan_ensure_alias_zwc "$alias_out"
    else
        echo "⚠️  Warning: jan alias generation failed (continuing)"
        print_info "   You can retry later with: jan alias --shell zsh -o \"$alias_out\""
    fi
    _libbeagan_trace "setup_scripts: jan alias + zcompile"

    print_info "   Writing host configuration to: $config_out"
    mkdir -p "$(dirname "$config_out")"
    if jan --no-log config emit --shell zsh -o "$config_out"; then
        print_info "✅ Emitted jan config shell fragments"
        # Do not source here — load_configurations sources once.
    else
        echo "⚠️  Warning: jan config emit failed (continuing)"
        print_info "   You can retry later with: jan config emit --shell zsh -o \"$config_out\""
    fi
    _libbeagan_trace "setup_scripts: jan config emit"

    print_info "   Running: jan config link"
    if jan --no-log config link; then
        print_info "✅ Linked config files into \$HOME (existing paths are skipped with a warning)"
    else
        echo "⚠️  Warning: jan config link failed (continuing)"
    fi
    _libbeagan_trace "setup_scripts: jan config link"

    print_info "   Running: jan config apply"
    if jan --no-log config apply; then
        print_info "✅ Applied imperative config (e.g. git config)"
    else
        echo "⚠️  Warning: jan config apply failed (continuing)"
    fi
    _libbeagan_trace "setup_scripts: jan config apply"
}

check_dependencies() {
    # Expensive inventory — only on explicit refresh, or when LIBBEAGAN_CHECK_DEPS=1.
    if [[ "$LIBBEAGAN_REFRESH" != "true" && "${LIBBEAGAN_CHECK_DEPS:-}" != "1" ]]; then
        print_info "📦 Skipping dependency check (pass --refresh or set LIBBEAGAN_CHECK_DEPS=1)"
        _libbeagan_trace "deps: skipped"
        return 0
    fi

    print_info "📦 Checking dependencies..."
    if command -v jan >/dev/null 2>&1; then
        if jan --no-log config deps; then
            print_info "✅ Dependency check finished (missing tools listed above if any)"
        else
            echo "⚠️  Warning: jan config deps failed (continuing)"
        fi
    else
        print_info "ℹ️  jan not on PATH — falling back to legacy dependencies.sh"
        safe_source "$LIBBEAGAN_HOME/dependencies.sh" "Dependencies"
    fi
    _libbeagan_trace "deps: done"
}

main() {
    validate_env || return 1
    _libbeagan_trace "validate_env"

    # Explicit refresh must re-source into the current shell (clear one-shot guards).
    if [[ "$LIBBEAGAN_REFRESH" == "true" ]]; then
        unset LIBBEAGAN_CONFIG_LOADED
        unset LIBBEAGAN_JAN_ALIASES_LOADED
        unset LIBBEAGAN_FRAMEWORK_LOADED
    fi

    # Refresh (optional) writes ~/.config/jan/{config,aliases}.zsh; then load once.
    setup_scripts || return 1
    _libbeagan_trace "setup_scripts (phase done)"
    load_configurations || return 1
    _libbeagan_trace "load_configurations (phase done)"
    load_aliases || return 1
    _libbeagan_trace "load_aliases (phase done)"
    setup_completions || return 1
    _libbeagan_trace "setup_completions (phase done)"
    check_dependencies || return 1
    _libbeagan_trace "check_dependencies (phase done)"

    print_info "🎉 libbeagan installation complete!"
    if [[ "$LIBBEAGAN_REFRESH" == "true" ]]; then
        print_info "   Type 'libbeagan_dependencies' or 'jan config deps' to check for missing tools."
        print_info "   Or run: refresh"
    else
        print_info "   Fast start (cached jan emit). Refresh with: refresh"
    fi
    print_info "   Tab completion is available for supported commands."
    _libbeagan_trace "main complete"
    _libbeagan_trace_summary
}

main
