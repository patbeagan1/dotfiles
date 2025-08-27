#!/usr/bin/env bash
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail

scriptname="$(basename "$0")"

# Test configuration
TEST_TEMP_DIR="/tmp/libbeagan-test-$$"
TEST_RESULTS_FILE="$TEST_TEMP_DIR/results.txt"

help() {
    cat << EOF
Usage: $scriptname [options]

Test libbeagan installation and scripts.

Options:
  -h, --help          Show this help message
  -v, --verbose       Verbose output
  --quick             Run only essential tests
  --full              Run all tests including slow ones
  --fix               Attempt to fix common issues

Examples:
  $scriptname --quick
  $scriptname --full --verbose
EOF
}

# Test utilities
test_log() {
    local level="$1"
    shift
    echo "[$level] $*" | tee -a "$TEST_RESULTS_FILE"
}

test_pass() {
    test_log "PASS" "$1"
}

test_fail() {
    test_log "FAIL" "$1"
    return 1
}

test_skip() {
    test_log "SKIP" "$1"
}

# Test functions
test_environment() {
    echo "Testing environment setup..."
    
    if [[ -n "${LIBBEAGAN_HOME:-}" ]]; then
        test_pass "LIBBEAGAN_HOME is set: $LIBBEAGAN_HOME"
    else
        test_fail "LIBBEAGAN_HOME is not set"
    fi
    
    if [[ -d "${LIBBEAGAN_HOME:-}" ]]; then
        test_pass "LIBBEAGAN_HOME directory exists"
    else
        test_fail "LIBBEAGAN_HOME directory does not exist"
    fi
}

test_script_permissions() {
    echo "Testing script permissions..."
    
    local script_dirs=(
        "scripts/android"
        "scripts/dev"
        "scripts/documentation"
        "scripts/file_management"
        "scripts/image_manipulation"
        "scripts/math"
        "scripts/sysadmin"
        "scripts/util"
        "scripts/vcs"
    )
    
    for dir in "${script_dirs[@]}"; do
        if [[ -d "$LIBBEAGAN_HOME/$dir" ]]; then
            local executable_count=0
            local total_count=0
            
            while IFS= read -r -d '' file; do
                total_count=$((total_count + 1))
                if [[ -x "$file" ]]; then
                    executable_count=$((executable_count + 1))
                else
                    test_log "WARN" "Script not executable: $file"
                fi
            done < <(find "$LIBBEAGAN_HOME/$dir" -type f -name "*.sh" -print0 2>/dev/null || true)
            
            if [[ $total_count -gt 0 ]]; then
                test_pass "Directory $dir: $executable_count/$total_count scripts executable"
            else
                test_skip "Directory $dir: no scripts found"
            fi
        else
            test_skip "Directory $dir: not found"
        fi
    done
}

test_essential_scripts() {
    echo "Testing essential scripts..."
    
    local essential_scripts=(
        "scripts/util/isMac.sh"
        "scripts/util/isLinux.sh"
        "scripts/util/machinetype.sh"
        "scripts/sysadmin/trackusage.sh"
        "scripts/file_management/basename.sh"
    )
    
    for script in "${essential_scripts[@]}"; do
        if [[ -f "$LIBBEAGAN_HOME/$script" ]]; then
            if [[ -x "$LIBBEAGAN_HOME/$script" ]]; then
                # Test basic execution
                if timeout 5s "$LIBBEAGAN_HOME/$script" >/dev/null 2>&1; then
                    test_pass "Script $script executes successfully"
                else
                    test_fail "Script $script fails to execute"
                fi
            else
                test_fail "Script $script is not executable"
            fi
        else
            test_fail "Script $script not found"
        fi
    done
}

test_dependencies() {
    echo "Testing dependencies..."
    
    # Test if libbeagan_dependencies function exists
    if command -v libbeagan_dependencies >/dev/null 2>&1; then
        test_pass "libbeagan_dependencies function available"
        
        # Run dependency check
        if libbeagan_dependencies >/dev/null 2>&1; then
            test_pass "Dependency check completed"
        else
            test_fail "Dependency check failed"
        fi
    else
        test_fail "libbeagan_dependencies function not available"
    fi
}

test_aliases() {
    echo "Testing aliases..."
    
    # Test if alias file can be sourced
    if [[ -f "$LIBBEAGAN_HOME/alias" ]]; then
        if source "$LIBBEAGAN_HOME/alias" >/dev/null 2>&1; then
            test_pass "Main alias file can be sourced"
        else
            test_fail "Main alias file fails to source"
        fi
    else
        test_fail "Main alias file not found"
    fi
}

test_config_files() {
    echo "Testing configuration files..."
    
    local config_files=(
        "configs/config-zsh.zsh"
        "configs/config-omzsh.zsh"
        "configs/config-golang.zsh"
        "configs/config-android.zsh"
    )
    
    for config in "${config_files[@]}"; do
        if [[ -f "$LIBBEAGAN_HOME/$config" ]]; then
            if source "$LIBBEAGAN_HOME/$config" >/dev/null 2>&1; then
                test_pass "Config file $config can be sourced"
            else
                test_fail "Config file $config fails to source"
            fi
        else
            test_skip "Config file $config not found"
        fi
    done
}

test_path_setup() {
    echo "Testing PATH setup..."
    
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
            if [[ ":$PATH:" == *":$script_path:"* ]]; then
                test_pass "Script directory $dir is in PATH"
            else
                test_fail "Script directory $dir is not in PATH"
            fi
        else
            test_skip "Script directory $dir not found"
        fi
    done
}

run_quick_tests() {
    echo "Running quick tests..."
    test_environment
    test_essential_scripts
    test_dependencies
    test_aliases
}

run_full_tests() {
    echo "Running full test suite..."
    run_quick_tests
    test_script_permissions
    test_config_files
    test_path_setup
}

show_results() {
    echo
    echo "=== Test Results ==="
    if [[ -f "$TEST_RESULTS_FILE" ]]; then
        local pass_count=$(grep -c "PASS" "$TEST_RESULTS_FILE" || echo "0")
        local fail_count=$(grep -c "FAIL" "$TEST_RESULTS_FILE" || echo "0")
        local skip_count=$(grep -c "SKIP" "$TEST_RESULTS_FILE" || echo "0")
        
        echo "Passed: $pass_count"
        echo "Failed: $fail_count"
        echo "Skipped: $skip_count"
        
        if [[ $fail_count -gt 0 ]]; then
            echo
            echo "Failed tests:"
            grep "FAIL" "$TEST_RESULTS_FILE"
        fi
        
        if [[ $fail_count -eq 0 ]]; then
            echo "✅ All tests passed!"
        else
            echo "❌ Some tests failed. Check the output above."
        fi
    else
        echo "No test results found."
    fi
}

cleanup() {
    rm -rf "$TEST_TEMP_DIR"
}

main() {
    # Parse arguments
    local verbose=false
    local quick=false
    local full=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --quick)
                quick=true
                shift
                ;;
            --full)
                full=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                help
                exit 1
                ;;
        esac
    done
    
    # Setup
    mkdir -p "$TEST_TEMP_DIR"
    trap cleanup EXIT
    
    echo "Starting libbeagan tests..."
    echo "Results will be saved to: $TEST_RESULTS_FILE"
    
    # Run tests
    if [[ "$full" == true ]]; then
        run_full_tests
    else
        run_quick_tests
    fi
    
    # Show results
    show_results
    
    # Exit with appropriate code
    if grep -q "FAIL" "$TEST_RESULTS_FILE" 2>/dev/null; then
        exit 1
    else
        exit 0
    fi
}

main "$@" 