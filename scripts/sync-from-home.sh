#!/usr/bin/env bash
# Sync from Home Script
# This script imports current machine configs into the dotfiles repository

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="${REPO_ROOT}/packages"

# Source common functions
source "${SCRIPT_DIR}/lib/common.sh"

# Mapping of source paths to package directories
declare -A MAPPING=(
    ["~/.config/zed"]="packages/editor-zed/.config/zed"
    ["~/.config/kitty"]="packages/term-kitty/.config/kitty"
    ["~/.config/i3"]="packages/wm-i3/.config/i3"
    ["~/.config/i3status"]="packages/wm-i3status/.config/i3status"
    ["~/.config/polybar"]="packages/bar-polybar/.config/polybar"
    ["~/.config/rofi"]="packages/launcher-rofi/.config/rofi"
    ["~/.config/dunst"]="packages/notify-dunst/.config/dunst"
    ["~/.config/picom"]="packages/compositor-picom/.config/picom"
    ["~/.config/sxhkd"]="packages/hotkeys-sxhkd/.config/sxhkd"
    ["~/.config/btop"]="packages/tools-btop/.config/btop"
    ["~/.config/fastfetch"]="packages/tools-fastfetch/.config/fastfetch"
    ["~/.config/Code/User"]="packages/editor-vscode/.config/Code/User"
    ["~/bin"]="packages/tools-superrice/bin"
)

# Exclusion patterns
EXCLUDE_PATTERNS=(
    "*.log"
    "*.tmp"
    "*.swp"
    "*.swo"
    "*.bak"
    "*.pid"
    "*.db"
    "*.sqlite"
    "*.sqlite3"
    "cache/"
    ".cache/"
    "logs/"
    "session/"
    "sessions/"
    "workspaceStorage/"
    "globalStorage/"
    "blob_storage/"
    "GPUCache/"
    "CachedData/"
    "History*"
    "Backups/"
    "token*"
    "auth*"
    "cookie*"
    "credential*"
    "machine-id*"
)

# Build rsync exclude arguments
build_exclude_args() {
    local args=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        args+=(--exclude="$pattern")
    done
    echo "${args[@]}"
}

main() {
    print_header "Sync from Home"

    local imported=0
    local skipped=0
    local excluded=0

    for source_path in "${!MAPPING[@]}"; do
        local target_path="${MAPPING[$source_path]}"
        local full_source="${source_path/#\~/$HOME}"
        local full_target="${REPO_ROOT}/${target_path}"

        log_info "Processing: $source_path -> $target_path"

        if [[ ! -d "$full_source" ]]; then
            log_warn "Source directory does not exist: $full_source"
            ((skipped++))
            continue
        fi

        # Create target directory
        mkdir -p "$(dirname "$full_target")"

        # Build rsync command
        local exclude_args=($(build_exclude_args))
        if rsync -a "${exclude_args[@]}" "$full_source/" "$full_target/"; then
            log_success "Imported: $source_path"
            ((imported++))
        else
            log_error "Failed to import: $source_path"
            ((skipped++))
        fi
    done

    echo
    log_info "Sync Summary:"
    log_info "  Imported: $imported"
    log_info "  Skipped: $skipped"
    log_info "  Excluded patterns: ${#EXCLUDE_PATTERNS[@]}"

    log_success "Sync completed"
}

main "$@"
