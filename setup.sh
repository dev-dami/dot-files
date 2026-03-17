#!/usr/bin/env bash
# Dotfiles Setup Script
# This script installs dotfiles using GNU Stow

set -euo pipefail

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"
PACKAGES_DIR="${REPO_ROOT}/packages"
MANIFESTS_DIR="${REPO_ROOT}/manifests"
SCRIPTS_DIR="${REPO_ROOT}/scripts"
LIB_DIR="${SCRIPTS_DIR}/lib"

# Default options
INTERACTIVE=true
WITH_OPTIONAL=false
INSTALL_DEPS=true
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load library functions
source "${LIB_DIR}/common.sh"
source "${LIB_DIR}/detect.sh"
source "${LIB_DIR}/install.sh"
source "${LIB_DIR}/backup.sh"
source "${LIB_DIR}/stow.sh"
source "${LIB_DIR}/fonts.sh"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        --with-optional)
            WITH_OPTIONAL=true
            shift
            ;;
        --no-install)
            INSTALL_DEPS=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--non-interactive] [--with-optional] [--no-install] [--dry-run]"
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_header "Dotfiles Setup"

    # Detect system
    detect_system

    # Load manifests
    load_manifests

    # Show summary
    show_summary

    # Ask for confirmation if interactive
    if [[ "$INTERACTIVE" == true ]]; then
        if ! confirm "Proceed with installation?"; then
            echo "Installation cancelled."
            exit 0
        fi
    fi

    # Install dependencies
    if [[ "$INSTALL_DEPS" == true ]]; then
        install_dependencies
    fi

    # Install fonts
    install_fonts

    # Backup conflicting files
    backup_conflicting_files

    # Stow packages
    stow_packages

    # Print completion message
    print_completion_message
}

load_manifests() {
    log_info "Loading manifests..."

    # Load core packages
    CORE_PACKAGES=()
    if [[ -f "${MANIFESTS_DIR}/core.txt" ]]; then
        while IFS= read -r package; do
            [[ "$package" =~ ^# ]] && continue
            [[ -z "$package" ]] && continue
            CORE_PACKAGES+=("$package")
        done < "${MANIFESTS_DIR}/core.txt"
    fi

    # Load optional packages
    OPTIONAL_PACKAGES=()
    if [[ -f "${MANIFESTS_DIR}/optional.txt" ]]; then
        while IFS= read -r package; do
            [[ "$package" =~ ^# ]] && continue
            [[ -z "$package" ]] && continue
            OPTIONAL_PACKAGES+=("$package")
        done < "${MANIFESTS_DIR}/optional.txt"
    fi

    # Load fonts
    FONTS=()
    if [[ -f "${MANIFESTS_DIR}/fonts.txt" ]]; then
        while IFS= read -r font; do
            [[ "$font" =~ ^# ]] && continue
            [[ -z "$font" ]] && continue
            FONTS+=("$font")
        done < "${MANIFESTS_DIR}/fonts.txt"
    fi
}

show_summary() {
    echo
    log_info "Configuration Summary"
    echo "---------------------"
    echo "Distro: $DISTRO_NAME ($DISTRO)"
    echo "Package Manager: $PKG_MANAGER"
    echo
    echo "Core packages (${#CORE_PACKAGES[@]}):"
    for pkg in "${CORE_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    echo
    if [[ "$WITH_OPTIONAL" == true ]] && [[ ${#OPTIONAL_PACKAGES[@]} -gt 0 ]]; then
        echo "Optional packages (${#OPTIONAL_PACKAGES[@]}):"
        for pkg in "${OPTIONAL_PACKAGES[@]}"; do
            echo "  - $pkg"
        done
        echo
    fi
    echo "Fonts (${#FONTS[@]}):"
    for font in "${FONTS[@]}"; do
        echo "  - $font"
    done
    echo
}

print_completion_message() {
    log_success "Dotfiles installation completed!"
    log_info "You may need to reload your window manager or terminal"
}

main "$@"
