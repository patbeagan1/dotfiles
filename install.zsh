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

    # Note: LIBBEAGAN_SCRIPTS validation is now handled by scripts/install.sh

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

load_configurations() {
    print_info "📁 Loading configurations..."
    safe_source "$LIBBEAGAN_HOME/configs/config-zsh.zsh" "ZSH configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-omzsh.zsh" "Oh My Zsh configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-golang.zsh" "Go configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-android.zsh" "Android configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-ios.zsh" "iOS configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-emacs.zsh" "emacs configuration"
}

load_machine_specific_config() {
    print_info "🖥️  Loading machine-specific configuration..."
    
    # Loop through all machine-specific configuration files
    local machines_dir="$LIBBEAGAN_HOME/configs/machines"
    if [[ -d "$machines_dir" ]]; then
        for machine_file in "$machines_dir"/*.zsh; do
            if [[ -f "$machine_file" ]]; then
                local machine_name=$(basename "$machine_file" .zsh)
                safe_source "$machine_file" "$machine_name configuration"
            fi
        done
    else
        print_info "ℹ️  No machines directory found at: $machines_dir"
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
    print_info "🔧 Setting up scripts..."
    if [[ -f "$LIBBEAGAN_SCRIPTS/install.sh" ]]; then
        source "$LIBBEAGAN_SCRIPTS/install.sh"
    else
        echo "⚠️  Warning: Script installation file not found at $LIBBEAGAN_SCRIPTS/install.sh"
        echo "   Scripts may not be properly configured."
    fi
}

check_dependencies() {
    print_info "📦 Checking dependencies..."
    safe_source "$LIBBEAGAN_HOME/dependencies.sh" "Dependencies"
}

main() {
    validate_env || return 1
    load_configurations || return 1
    load_machine_specific_config || return 1
    setup_scripts || return 1
    load_aliases || return 1
    setup_completions || return 1
    check_dependencies || return 1

    print_info "🎉 libbeagan installation complete!"
    print_info "   Type 'libbeagan_dependencies' to check for missing tools."
    print_info "   Tab completion is available for supported commands."
}

main
