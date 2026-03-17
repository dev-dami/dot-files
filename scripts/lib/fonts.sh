# Font installation functions

install_fonts() {
    log_info "Checking and installing fonts..."

    local fonts_file="${MANIFESTS_DIR}/fonts.txt"
    if [[ ! -f "$fonts_file" ]]; then
        log_warn "Fonts manifest not found, skipping font installation"
        return 0
    fi

    local missing_fonts=()
    while IFS= read -r font; do
        # Skip comments and empty lines
        [[ "$font" =~ ^# ]] && continue
        [[ -z "$font" ]] && continue

        if ! check_font "$font"; then
            missing_fonts+=("$font")
        fi
    done < "$fonts_file"

    if [[ ${#missing_fonts[@]} -eq 0 ]]; then
        log_success "All fonts already installed"
        return 0
    fi

    if [[ "$INTERACTIVE" == true ]]; then
        echo "The following fonts are missing:"
        for font in "${missing_fonts[@]}"; do
            echo "  - $font"
        done
        if ! confirm "Install missing fonts?"; then
            log_warn "Skipping font installation"
            return 0
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "DRY RUN: Would install fonts: ${missing_fonts[*]}"
        return 0
    fi

    # Try to install fonts through package manager
    local installed_count=0
    for font in "${missing_fonts[@]}"; do
        # Try to install via package manager
        local package_name=""
        case "$font" in
            *"JetBrainsMono Nerd Font"*)
                package_name="ttf-jetbrains-mono-nerd"
                ;;
            *"Maple Mono NF"*)
                package_name="ttf-maple-mono"
                ;;
            *)
                package_name=""
                ;;
        esac

        if [[ -n "$package_name" ]] && [[ "$PKG_MANAGER" != "unknown" ]]; then
            log_info "Installing $font via $package_name..."
            case "$PKG_MANAGER" in
                apt)
                    sudo apt-get install -y "$package_name" && ((installed_count++))
                    ;;
                pacman)
                    sudo pacman -S --noconfirm "$package_name" && ((installed_count++))
                    ;;
                dnf|yum)
                    sudo dnf install -y "$package_name" && ((installed_count++))
                    ;;
            esac
        else
            log_warn "Manual installation required for: $font"
        fi
    done

    # Refresh font cache
    if command_exists fc-cache; then
        log_info "Refreshing font cache..."
        fc-cache -f -v
    fi

    if [[ $installed_count -gt 0 ]]; then
        log_success "Installed $installed_count font(s) via package manager"
    fi
}
