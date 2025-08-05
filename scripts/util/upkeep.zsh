#!/bin/zsh

###############################################################################
# upkeep.zsh - Strict, cross-language, yearly maintenance script
# Languages: Python, Node.js, Rust, Kotlin
# Features: Cache cleanup, update, format, lint, test, LICENSE update, Git tag
###############################################################################

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/projects/my-project}"
LICENSE_FILE="$PROJECT_DIR/LICENSE"
CURRENT_YEAR=$(date +%Y)
TAG_NAME="upkeep-$CURRENT_YEAR"
LOG_FILE="$PROJECT_DIR/upkeep-$CURRENT_YEAR.log"

if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

cd "$PROJECT_DIR" || { echo "❌ Project directory not found: $PROJECT_DIR"; exit 1 }

log() { echo "🔹 $1"; }
warn() { echo "⚠️  $1"; }
die() { echo "❌ $1"; exit 1; }

check_tool() {
  local cmd="$1"
  local min_version="$2"
  local version_command="$3"

  if ! command -v "$cmd" >/dev/null; then
    die "Required tool '$cmd' is not installed."
  fi

  local version
  version=$(eval "$version_command") || die "Failed to get version of $cmd"
  log "$cmd version: $version"

  # Optional: implement version comparison if strict matching is needed
}

clean_common_caches() {
  log "🧹 Cleaning cache files..."
  find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null
  find . -type f \( -name "*.pyc" -o -name "*~" \) -delete
}

update_license_year() {
  if [[ -f "$LICENSE_FILE" ]]; then
    log "📜 Updating LICENSE year to $CURRENT_YEAR..."
    sed "${SED_INPLACE[@]}" -E "s/(Copyright [0-9]{4})(-[0-9]{4})?/\1-$CURRENT_YEAR/" "$LICENSE_FILE"
  else
    warn "LICENSE file not found."
  fi
}

write_log() {
  log "📝 Writing log to $LOG_FILE"
  {
    echo "Upkeep run on $(date)"
    echo "Python: $(python3 --version 2>/dev/null || echo 'Not installed')"
    echo "uv: $(uv --version 2>/dev/null || echo 'Not installed')"
    echo "Node: $(node --version 2>/dev/null || echo 'Not installed')"
    echo "Rust: $(rustc --version 2>/dev/null || echo 'Not installed')"
    echo "Kotlin: $(kotlinc -version 2>/dev/null || echo 'Not installed')"
  } > "$LOG_FILE"
}

git_commit_and_tag() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    log "🔄 Committing and tagging in Git..."
    git add .
    git commit -m "🔧 Yearly upkeep: $CURRENT_YEAR" || warn "Nothing to commit."

    if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
      warn "Tag $TAG_NAME already exists. Skipping."
    else
      git tag "$TAG_NAME"
      git push origin "$(git rev-parse --abbrev-ref HEAD)" --tags
    fi
  else
    warn "Not a Git repository."
  fi
}

# === PYTHON ===

handle_python_project() {
  [[ ! -f "pyproject.toml" ]] && return
  log "🐍 Python project detected"

  check_tool uv "0.1.0" "uv --version"
  check_tool python3 "3.8.0" "python3 --version"
  check_tool black "22.0" "uv pip run black --version"
  check_tool flake8 "5.0" "uv pip run flake8 --version"
  check_tool pytest "7.0" "uv pip run pytest --version"

  function update_python_deps() {
    log "📦 Updating Python dependencies via uv..."
    uv self upgrade
    uv pip install -U uv black flake8 pytest
    uv pip sync --upgrade
  }

  function format_python_code() {
    log "🎨 Formatting Python code..."
    uv pip run black .
  }

  function lint_python_code() {
    log "🔍 Linting Python code..."
    uv pip run flake8 .
  }

  function test_python_code() {
    log "🧪 Running Python tests..."
    uv pip run pytest
  }

  update_python_deps
  format_python_code
  lint_python_code
  test_python_code
}

# === NODE.JS ===

handle_node_project() {
  [[ ! -f "package.json" ]] && return
  log "📦 Node.js project detected"

  check_tool node "16.0.0" "node --version"
  check_tool npm "8.0.0" "npm --version"
  check_tool npx "8.0.0" "npx --version"

  function update_node_deps() {
    log "⬆️ Updating Node.js dependencies..."
    npm update
  }

  function lint_node_code() {
    if [[ -f ".eslintrc.js" || -f ".eslintrc.json" ]]; then
      check_tool eslint "8.0.0" "npx eslint --version"
      log "🔍 Linting JS/TS code..."
      npx eslint .
    fi
  }

  function format_node_code() {
    if [[ -f "prettier.config.js" || -f ".prettierrc" ]]; then
      check_tool prettier "2.0.0" "npx prettier --version"
      log "🎨 Formatting code with Prettier..."
      npx prettier --write .
    fi
  }

  function test_node_code() {
    log "🧪 Running Node.js tests..."
    npm test
  }

  update_node_deps
  lint_node_code
  format_node_code
  test_node_code
}

# === RUST ===

handle_rust_project() {
  [[ ! -f "Cargo.toml" ]] && return
  log "🦀 Rust project detected"

  check_tool cargo "1.60" "cargo --version"

  function update_rust_deps() {
    log "⬆️ Updating Rust dependencies..."
    cargo update
  }

  function format_rust_code() {
    log "🎨 Formatting Rust code..."
    cargo fmt
  }

  function lint_rust_code() {
    log "🔍 Linting Rust code..."
    cargo clippy
  }

  function test_rust_code() {
    log "🧪 Running Rust tests..."
    cargo test
  }

  update_rust_deps
  format_rust_code
  lint_rust_code
  test_rust_code
}

# === KOTLIN ===

handle_kotlin_project() {
  [[ ! -f "build.gradle.kts" && ! -f "build.gradle" ]] && return
  log "🤖 Kotlin/Gradle project detected"

  check_tool ./gradlew "7.0" "./gradlew --version | grep Gradle"

  function update_kotlin_deps() {
    log "⬆️ Checking Kotlin dependency updates..."
    ./gradlew dependencyUpdates
  }

  function format_kotlin_code() {
    if grep -q "ktlint" build.gradle*; then
      log "🎨 Formatting Kotlin code with ktlint..."
      ./gradlew ktlintFormat
    elif grep -q "spotless" build.gradle*; then
      log "🎨 Formatting Kotlin code with Spotless..."
      ./gradlew spotlessApply
    else
      warn "No Kotlin formatter configured"
    fi
  }

  function lint_kotlin_code() {
    if grep -q "detekt" build.gradle*; then
      log "🔍 Linting Kotlin code with detekt..."
      ./gradlew detekt
    else
      warn "No Kotlin linter configured"
    fi
  }

  function test_kotlin_code() {
    log "🧪 Running Kotlin tests..."
    ./gradlew test
  }

  update_kotlin_deps
  format_kotlin_code
  lint_kotlin_code
  test_kotlin_code
}

# === MAIN ===

main() {
  log "🚀 Running strict yearly upkeep on: $PROJECT_DIR"
  echo "📆 $(date)"

  clean_common_caches

  handle_python_project
  handle_node_project
  handle_rust_project
  handle_kotlin_project

  update_license_year
  write_log
  git_commit_and_tag

  log "✅ Yearly upkeep complete."
}

main "$@"
