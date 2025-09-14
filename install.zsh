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
}


load_aliases() {
    print_info "📝 Loading aliases..."
    safe_source "$LIBBEAGAN_HOME/alias" "Main alias file"
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
    setup_scripts || return 1
    load_aliases || return 1
    setup_completions || return 1
    check_dependencies || return 1

    print_info "🎉 libbeagan installation complete!"
    print_info "   Type 'libbeagan_dependencies' to check for missing tools."
    print_info "   Tab completion is available for supported commands."
}

main
