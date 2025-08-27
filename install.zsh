#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

echo "Welcome to libbeagan."

# Validate LIBBEAGAN_HOME
if [[ ! -v LIBBEAGAN_HOME ]]; then
    echo '❌ Error: LIBBEAGAN_HOME environment variable is not set.'
    echo '   Please add the following to your ~/.zshrc file:'
    echo '   export LIBBEAGAN_HOME="$HOME/libbeagan"'
    echo
    return 1
fi

# Validate the directory exists
if [[ ! -d "$LIBBEAGAN_HOME" ]]; then
    echo "❌ Error: LIBBEAGAN_HOME directory does not exist: $LIBBEAGAN_HOME"
    echo "   Please ensure the path is correct."
    return 1
fi

echo "✅ Using libbeagan from: $LIBBEAGAN_HOME"

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

###########################################################
# Configurations
# Personal settings that modify the environment
###########################################################
echo "📁 Loading configurations..."
safe_source "$LIBBEAGAN_HOME/configs/config-zsh.zsh" "ZSH configuration"
safe_source "$LIBBEAGAN_HOME/configs/config-omzsh.zsh" "Oh My Zsh configuration"
safe_source "$LIBBEAGAN_HOME/configs/config-golang.zsh" "Go configuration"
safe_source "$LIBBEAGAN_HOME/configs/config-android.zsh" "Android configuration"
safe_source "$LIBBEAGAN_HOME/configs/config-ios.zsh" "iOS configuration"

###########################################################
# Personal scripts
# Add script directories to PATH
###########################################################
echo "🔧 Adding script directories to PATH..."
# Add dist directory to PATH (contains symlinks to all scripts)
local dist_path="$LIBBEAGAN_HOME/scripts/dist"
if [[ -d "$dist_path" ]]; then
    export PATH="$PATH:$dist_path"
    echo "✅ Added scripts dist directory to PATH"
else
    echo "⚠️  Warning: Scripts dist directory not found: $dist_path"
    echo "   Run 'organize-scripts.sh --publish' to create it"
    
    # Fallback: add individual script directories for backward compatibility
    local script_dirs=(
        "android"
        "dev"
        "documentation"
        "file_management"
        "image_manipulation"
        "math"
        "sysadmin"
        "util"
        "vcs"
    )

    for dir in "${script_dirs[@]}"; do
        local script_path="$LIBBEAGAN_HOME/scripts/$dir"
        if [[ -d "$script_path" ]]; then
            export PATH="$PATH:$script_path"
            echo "✅ Added to PATH: $dir"
        else
            echo "⚠️  Warning: Script directory not found: $script_path"
        fi
    done
fi

###########################################################
# Aliases
###########################################################
echo "📝 Loading aliases..."

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

# Source the main alias file
safe_source "$LIBBEAGAN_HOME/alias" "Main alias file"

###########################################################
# Completions
###########################################################
echo "🔧 Setting up Zsh completions..."
local completions_dir="$LIBBEAGAN_HOME/completions"
if [[ -d "$completions_dir" ]]; then
    # Add completions directory to fpath if not already present
    if [[ ! "$fpath" =~ "$completions_dir" ]]; then
        fpath=("$completions_dir" $fpath)
        echo "✅ Added completions directory to fpath"
        
        # Initialize completions if compinit is available
        if command -v compinit >/dev/null 2>&1; then
            autoload -Uz compinit && compinit
            echo "✅ Initialized Zsh completions"
        fi
    else
        echo "✅ Completions directory already in fpath"
    fi
else
    echo "⚠️  Warning: Completions directory not found: $completions_dir"
fi

###########################################################
# Dependencies
###########################################################
echo "📦 Checking dependencies..."
safe_source "$LIBBEAGAN_HOME/dependencies.sh" "Dependencies"

echo "🎉 libbeagan installation complete!"
echo "   Type 'libbeagan_dependencies' to check for missing tools."
echo "   Tab completion is available for supported commands."
