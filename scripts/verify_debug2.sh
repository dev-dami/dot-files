#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="${REPO_ROOT}/packages"
MANIFESTS_DIR="${REPO_ROOT}/manifests"
SCRIPTS_DIR="${REPO_ROOT}/scripts"

source "${SCRIPT_DIR}/lib/common.sh"

main() {
    echo "DEBUG: Starting main"
    print_header "Verify Repository"
    local errors=0 warnings=0
    
    echo "DEBUG: Checking required tools..."
    log_info "Checking required tools..."
    local required_tools=("jq" "stow")
    for tool in "${required_tools[@]}"; do
        echo "DEBUG: Checking tool $tool"
        if command_exists "$tool"; then
            log_success "$tool is available"
        else
            log_warn "$tool is not available (some checks will be skipped)"
            ((warnings++))
            echo "DEBUG: warnings now $warnings"
        fi
    done
    echo "DEBUG: Tool check complete, warnings=$warnings"
    echo
    
    echo "DEBUG: About to check manifest files..."
    echo "DEBUG: MANIFESTS_DIR=$MANIFESTS_DIR"
    echo "DEBUG: Listing manifest files..."
    ls -la "$MANIFESTS_DIR"
    echo
    
    echo "DEBUG: Exiting normally"
    exit 0
}

main "$@"
