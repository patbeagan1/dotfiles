#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

# Verbose mode - quiet by default, enable with VERBOSE=true or --verbose
VERBOSE_MODE=${VERBOSE_MODE:-false}

# Check for --verbose flag
if [[ "$1" == "--verbose" ]]; then
    VERBOSE_MODE=true
fi

# Function to print messages only if in verbose mode
print_info() {
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo "$@"
    fi
}

print_info "Welcome to libbeagan."

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

load_configurations() {
    # Preferred path: emitted by `jan config emit` in setup_scripts.
    local emitted="${XDG_CONFIG_HOME:-$HOME/.config}/jan/config.zsh"
    if [[ -f "$emitted" ]]; then
        print_info "📁 Loading jan-emitted configuration: $emitted"
        # shellcheck disable=SC1090
        source "$emitted"
        return 0
    fi

    print_info "📁 Loading configurations (legacy configs/*.zsh; run install with jan for emit)..."
    safe_source "$LIBBEAGAN_HOME/configs/config-zsh.zsh" "ZSH configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-omzsh.zsh" "Oh My Zsh configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-golang.zsh" "Go configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-android.zsh" "Android configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-ios.zsh" "iOS configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-emacs.zsh" "emacs configuration"

    local machines_dir="$LIBBEAGAN_HOME/configs/machines"
    if [[ -d "$machines_dir" ]]; then
        for machine_file in "$machines_dir"/*.zsh(N); do
            [[ -f "$machine_file" ]] || continue
            local machine_name="${machine_file:t:r}"
            safe_source "$machine_file" "$machine_name configuration"
        done
    fi
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
        fi
    done
}

load_aliases() {
    print_info "📝 Loading aliases..."
    safe_source "$LIBBEAGAN_HOME/alias" "Main alias file"
    _libbeagan_load_aliases
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

    # Initialize completions if needed
    if [[ "$need_compinit" == "true" ]]; then
        if command -v compinit >/dev/null 2>&1; then
            autoload -Uz compinit && compinit
            print_info "✅ Initialized Zsh completions"
        fi
    fi
}

setup_scripts() {
    print_info "🔧 Setting up scripts / jan utilities..."
    export PATH=$PATH:$LIBBEAGAN_HOME/bin:$LIBBEAGAN_HOME/bin_local
    print_info "   PATH prepended with: $LIBBEAGAN_HOME/bin and $LIBBEAGAN_HOME/bin_local"

    local jan_dir="${LIBBEAGAN_HOME}/jan"
    print_info "   Looking for jan tree at: $jan_dir"

    if [[ ! -d "$jan_dir" ]]; then
        print_info "ℹ️  No jan tree at $jan_dir — skipping jan prefer / alias setup"
        print_info "   Sync or copy dotfiles/jan there to enable personal utilities via jan"
        return 0
    fi
    print_info "✅ Found jan tree: $jan_dir"

    if ! command -v jan >/dev/null 2>&1; then
        print_info "ℹ️  jan binary not on PATH — tree is present but not activated"
        print_info "   Install jan-cli, then re-run install or: jan use \"$jan_dir\""
        return 0
    fi
    print_info "   jan binary: $(command -v jan)"

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

    local alias_out="${XDG_CONFIG_HOME:-$HOME/.config}/jan/scripts/aliases.zsh"
    print_info "   Writing shell aliases to: $alias_out"
    mkdir -p "$(dirname "$alias_out")"
    if jan --no-log alias --shell zsh -o "$alias_out"; then
        local alias_count
        alias_count="$(grep -c '^alias ' "$alias_out" 2>/dev/null || echo 0)"
        print_info "✅ Generated $alias_count alias(es) in $alias_out"
        # shellcheck disable=SC1090
        source "$alias_out"
        print_info "✅ Sourced jan aliases into current shell"
    else
        echo "⚠️  Warning: jan alias generation failed (continuing)"
        print_info "   You can retry later with: jan alias --shell zsh -o \"$alias_out\""
    fi

    local config_out="${XDG_CONFIG_HOME:-$HOME/.config}/jan/config.zsh"
    print_info "   Writing host configuration to: $config_out"
    mkdir -p "$(dirname "$config_out")"
    if jan --no-log config emit --shell zsh -o "$config_out"; then
        print_info "✅ Emitted jan config shell fragments"
        # shellcheck disable=SC1090
        source "$config_out"
        print_info "✅ Sourced jan config into current shell"
    else
        echo "⚠️  Warning: jan config emit failed (continuing)"
        print_info "   You can retry later with: jan config emit --shell zsh -o \"$config_out\""
    fi

    print_info "   Running: jan config link"
    if jan --no-log config link; then
        print_info "✅ Linked config files into \$HOME (existing paths are skipped with a warning)"
    else
        echo "⚠️  Warning: jan config link failed (continuing)"
    fi

    print_info "   Running: jan config apply"
    if jan --no-log config apply; then
        print_info "✅ Applied imperative config (e.g. git config)"
    else
        echo "⚠️  Warning: jan config apply failed (continuing)"
    fi
}

check_dependencies() {
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
}

main() {
    validate_env || return 1
    # jan use / alias / config emit+link+apply first so load_configurations can
    # source the emitted ~/.config/jan/config.zsh (machine fragments included).
    setup_scripts || return 1
    load_configurations || return 1
    load_aliases || return 1
    setup_completions || return 1
    check_dependencies || return 1

    print_info "🎉 libbeagan installation complete!"
    print_info "   Type 'libbeagan_dependencies' or 'jan config deps' to check for missing tools."
    print_info "   Tab completion is available for supported commands."
}

main
