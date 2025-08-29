#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

echo "Welcome to libbeagan."

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
        echo "✅ Using libbeagan from: $LIBBEAGAN_HOME"
    fi

    # Validate LIBBEAGAN_SCRIPTS (with fallback)
    if [[ ! -v LIBBEAGAN_SCRIPTS ]]; then
        echo '❌ Error: LIBBEAGAN_SCRIPTS environment variable is not set and cannot fallback.'
        echo '   Please add the following to your ~/.zshrc file:'
        echo '   export LIBBEAGAN_SCRIPTS="$HOME/libbeagan/scripts"'
        echo
        has_errors=true
    elif [[ ! -d "$LIBBEAGAN_SCRIPTS" ]]; then
        echo "❌ Error: LIBBEAGAN_SCRIPTS directory does not exist: $LIBBEAGAN_SCRIPTS"
        echo "   Please ensure the path is correct."
        has_errors=true
    else
        echo "✅ Using scripts from: $LIBBEAGAN_SCRIPTS"
    fi

    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

load_configurations() {
    echo "📁 Loading configurations..."
    safe_source "$LIBBEAGAN_HOME/configs/config-zsh.zsh" "ZSH configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-omzsh.zsh" "Oh My Zsh configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-golang.zsh" "Go configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-android.zsh" "Android configuration"
    safe_source "$LIBBEAGAN_HOME/configs/config-ios.zsh" "iOS configuration"
}

add_script_paths() {
    echo "🔧 Adding script directories to PATH..."
    local dist_path="$LIBBEAGAN_SCRIPTS/dist"
    if [[ -d "$dist_path" ]]; then
        export PATH="$PATH:$dist_path"
        echo "✅ Added scripts dist directory to PATH"
    else
        echo "⚠️  Warning: Scripts dist directory not found: $dist_path"
        echo "   Run 'organize-scripts.sh --publish' to create it"
    fi
}

load_aliases() {
    echo "📝 Loading aliases..."
    safe_source "$LIBBEAGAN_HOME/alias" "Main alias file"
}

setup_completions() {
    echo "🔧 Setting up Zsh completions..."

    local completions_dir="$LIBBEAGAN_HOME/completions"
    local script_completions_dir="$LIBBEAGAN_SCRIPTS/completions"
    local need_compinit=false

    # Add main completions directory
    if [[ -d "$completions_dir" ]]; then
        if [[ ! "$fpath" =~ "$completions_dir" ]]; then
            fpath=("$completions_dir" $fpath)
            echo "✅ Added main completions directory to fpath"
            need_compinit=true
        else
            echo "✅ Main completions directory already in fpath"
        fi
    else
        echo "⚠️  Warning: Main completions directory not found: $completions_dir"
    fi

    # Add script completions directory
    if [[ -d "$script_completions_dir" ]]; then
        if [[ ! "$fpath" =~ "$script_completions_dir" ]]; then
            fpath=("$script_completions_dir" $fpath)
            echo "✅ Added script completions directory to fpath"
            need_compinit=true
        else
            echo "✅ Script completions directory already in fpath"
        fi
    else
        echo "⚠️  Warning: Script completions directory not found: $script_completions_dir"
        echo "   Run 'organize-scripts.sh --publish' to create it"
    fi

    # Initialize completions if needed
    if [[ "$need_compinit" == "true" ]]; then
        if command -v compinit >/dev/null 2>&1; then
            autoload -Uz compinit && compinit
            echo "✅ Initialized Zsh completions"
        fi
    fi
}

check_dependencies() {
    echo "📦 Checking dependencies..."
    safe_source "$LIBBEAGAN_HOME/dependencies.sh" "Dependencies"
}

main() {
    validate_env || return 1
    load_configurations || return 1
    add_script_paths || return 1
    load_aliases || return 1
    setup_completions || return 1
    check_dependencies || return 1

    echo "🎉 libbeagan installation complete!"
    echo "   Type 'libbeagan_dependencies' to check for missing tools."
    echo "   Tab completion is available for supported commands."
}

main
