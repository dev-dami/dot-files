#!/usr/bin/env bash
set -euo pipefail

# Absolute path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="${REPO_ROOT}/packages"
MANIFESTS_DIR="${REPO_ROOT}/manifests"
SCRIPTS_DIR="${REPO_ROOT}/scripts"

# Source common functions
source "${SCRIPT_DIR}/lib/common.sh"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

main() {
    print_header "Verify Repository"
    local errors=0 warnings=0

    # 1. Check required tools
    log_info "Checking required tools..."
    local required_tools=("jq" "stow")
    for tool in "${required_tools[@]}"; do
        if command_exists "$tool"; then
            log_success "$tool is available"
        else
            log_warn "$tool is not available (some checks will be skipped)"
            warnings=$((warnings + 1))
        fi
    done
    echo

    # 2. Check manifest files
    log_info "Checking manifest files..."
    for manifest in core.txt optional.txt system-packages.txt fonts.txt; do
        if [[ ! -f "${MANIFESTS_DIR}/${manifest}" ]]; then
            log_error "Missing manifest: $manifest"
            errors=$((errors + 1))
        else
            log_success "Found: $manifest"
        fi
    done
    echo

    # 3. Check package directories exist
    log_info "Checking package directories..."
    while IFS= read -r package; do
        [[ "$package" =~ ^# ]] && continue
        [[ -z "$package" ]] && continue
        local package_dir="${PACKAGES_DIR}/${package}"
        if [[ ! -d "$package_dir" ]]; then
            log_error "Missing package directory: $package"
            errors=$((errors + 1))
        else
            log_success "Found package: $package"
        fi
    done < "${MANIFESTS_DIR}/core.txt"
    echo

    # 4. Validate JSON files (skip JSONC/Zed files)
    log_info "Validating JSON files (skipping JSONC)..."
    local json_errors=0 json_skipped=0 json_files_found=0
    
    # Use find with -print0 and process with while loop
    find "$PACKAGES_DIR" -name "*.json" -type f -print0 2>/dev/null | while IFS= read -r -d '' json_file; do
        [[ -z "$json_file" ]] && continue
        json_files_found=$((json_files_found + 1))
        
        # Skip Zed JSON files (JSONC format with comments)
        if [[ "$json_file" == *"/zed"* ]]; then
            json_skipped=$((json_skipped + 1))
            continue
        fi
        
        # Validate standard JSON
        if timeout 2 jq empty "$json_file" >/dev/null 2>&1; then
            # Valid JSON
            :
        else
            log_error "Invalid JSON: $json_file"
            json_errors=$((json_errors + 1))
        fi
    done
    
    if [[ $json_errors -eq 0 ]]; then
        log_success "JSON validation passed ($json_files_found found, $json_skipped skipped)"
    else
        log_error "Found $json_errors invalid JSON file(s)"
        errors=$((errors + 1))
    fi
    echo

    # 5. Check system packages manifest
    log_info "Checking system packages manifest..."
    local dup_count=0 seen=()
    while IFS= read -r package; do
        [[ "$package" =~ ^# ]] && continue
        [[ -z "$package" ]] && continue
        if [[ " ${seen[@]} " =~ " ${package} " ]]; then
            log_warn "Duplicate package: $package"
            dup_count=$((dup_count + 1))
        else
            seen+=("$package")
        fi
    done < "${MANIFESTS_DIR}/system-packages.txt"
    if [[ $dup_count -eq 0 ]]; then
        log_success "No duplicate packages in manifest"
    else
        log_warn "Found $dup_count duplicate package(s)"
        ((warnings++))
    fi
    echo

    # 6. Check for broken symlinks
    log_info "Checking for broken symlinks..."
    local broken_symlinks=0
    while IFS= read -r -d '' symlink; do
        if [[ ! -e "$symlink" ]]; then
            log_error "Broken symlink: $symlink"
            broken_symlinks=$((broken_symlinks + 1))
        fi
    done < <(find "$PACKAGES_DIR" -type l -print0 2>/dev/null)
    if [[ $broken_symlinks -eq 0 ]]; then
        log_success "No broken symlinks found"
    else
        log_error "Found $broken_symlinks broken symlink(s)"
        errors=$((errors + 1))
    fi
    echo

    # 7. Dependency mapping verification (apt vs pacman)
    log_info "Checking system dependencies..."
    local dep_manager=""
    if command_exists "apt"; then
        dep_manager="apt"
        log_success "apt package manager detected"
    elif command_exists "pacman"; then
        dep_manager="pacman"
        log_success "pacman package manager detected"
    else
        log_warn "Neither apt nor pacman detected"
        ((warnings++))
    fi
    echo

    # 8. Script permissions check
    log_info "Checking script permissions..."
    local script_errors=0
    if [[ -f "${REPO_ROOT}/setup.sh" ]]; then
        if [[ ! -x "${REPO_ROOT}/setup.sh" ]]; then
            log_warn "setup.sh is not executable"
            script_errors=$((script_errors + 1))
        fi
    fi
    if [[ $script_errors -eq 0 ]]; then
        log_success "Script permissions OK"
    else
        ((warnings++))
    fi
    echo

    # Final Summary
    log_info "Verification Summary:"
    log_info "  Errors: $errors"
    log_info "  Warnings: $warnings"
    echo

    if [[ $errors -eq 0 ]]; then
        log_success "Repository verification passed"
        exit 0
    else
        log_error "Repository verification failed with $errors error(s)"
        exit 1
    fi
}

main "$@"
