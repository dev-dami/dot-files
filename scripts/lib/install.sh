# Installation functions

install_dependencies() {
    log_info "Installing system dependencies..."

    # Read system packages manifest
    local system_packages_file="${MANIFESTS_DIR}/system-packages.txt"
    if [[ ! -f "$system_packages_file" ]]; then
        log_warn "System packages manifest not found, skipping dependency installation"
        return 0
    fi

    # Collect missing packages
    local missing_packages=()
    while IFS= read -r package; do
        # Skip comments and empty lines
        [[ "$package" =~ ^# ]] && continue
        [[ -z "$package" ]] && continue

        if ! check_package "$package"; then
            missing_packages+=("$package")
        fi
    done < "$system_packages_file"

    # Install missing packages
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        log_success "All dependencies already installed"
        return 0
    fi

    if [[ "$INTERACTIVE" == true ]]; then
        echo "The following packages will be installed:"
        for pkg in "${missing_packages[@]}"; do
            echo "  - $pkg"
        done
        if ! confirm "Proceed with installation?"; then
            log_warn "Skipping dependency installation"
            return 0
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "DRY RUN: Would install: ${missing_packages[*]}"
        return 0
    fi

    case "$PKG_MANAGER" in
        apt)
            $PKG_UPDATE
            $PKG_INSTALL "${missing_packages[@]}"
            ;;
        pacman)
            $PKG_INSTALL "${missing_packages[@]}"
            ;;
        dnf|yum)
            $PKG_INSTALL "${missing_packages[@]}"
            ;;
        *)
            log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    log_success "Dependencies installed successfully"
}

get_package_manager() {
    echo "$PKG_MANAGER"
}
