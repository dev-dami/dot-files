# Stow functions

stow_packages() {
    log_info "Stowing packages..."

    # Check if stow is available
    if ! command_exists stow; then
        log_error "GNU Stow is not installed. Please install it first."
        return 1
    fi

    # Determine which packages to stow
    local packages_to_stow=()
    if [[ "$WITH_OPTIONAL" == true ]]; then
        # Load optional packages
        local optional_file="${MANIFESTS_DIR}/optional.txt"
        if [[ -f "$optional_file" ]]; then
            while IFS= read -r package; do
                [[ "$package" =~ ^# ]] && continue
                [[ -z "$package" ]] && continue
                packages_to_stow+=("$package")
            done < "$optional_file"
        fi
    fi

    # Load core packages
    local core_file="${MANIFESTS_DIR}/core.txt"
    if [[ ! -f "$core_file" ]]; then
        log_error "Core manifest not found"
        return 1
    fi

    while IFS= read -r package; do
        [[ "$package" =~ ^# ]] && continue
        [[ -z "$package" ]] && continue
        packages_to_stow+=("$package")
    done < "$core_file"

    # Stow each package
    local stowed_count=0
    for package in "${packages_to_stow[@]}"; do
        local package_dir="${PACKAGES_DIR}/${package}"
        if [[ ! -d "$package_dir" ]]; then
            log_warn "Package directory not found: $package"
            continue
        fi

        log_info "Stowing $package..."

        if [[ "$DRY_RUN" == true ]]; then
            log_info "DRY RUN: Would stow $package from $package_dir to $HOME"
            ((stowed_count++))
            continue
        fi

        cd "$PACKAGES_DIR"

        # Special handling for tools-superrice package (bin directory)
        if [[ "$package" == "tools-superrice" ]]; then
            # Create bin directory if it doesn't exist
            mkdir -p "$HOME/bin"
            # Copy superrice scripts to ~/bin
            if cp -r "${package_dir}/bin/"* "$HOME/bin/" 2>/dev/null; then
                log_success "Installed superrice scripts to ~/bin"
                ((stowed_count++))
            else
                log_error "Failed to install superrice scripts"
            fi
        else
            if stow -t "$HOME" "$package"; then
                log_success "Stowed $package"
                ((stowed_count++))
            else
                log_error "Failed to stow $package"
            fi
        fi
    done

    # Return to original directory
    cd "$REPO_ROOT"

    log_success "Stowed $stowed_count package(s)"
}
