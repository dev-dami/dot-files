# Backup functions

backup_conflicting_files() {
    log_info "Backing up conflicting files..."

    local backup_count=0
    local timestamp=$(get_timestamp)

    # Read core manifest to get package list
    local core_manifest="${MANIFESTS_DIR}/core.txt"
    if [[ ! -f "$core_manifest" ]]; then
        log_warn "Core manifest not found, skipping backup"
        return 0
    fi

    while IFS= read -r package; do
        # Skip comments and empty lines
        [[ "$package" =~ ^# ]] && continue
        [[ -z "$package" ]] && continue

        local package_dir="${PACKAGES_DIR}/${package}"
        if [[ ! -d "$package_dir" ]]; then
            continue
        fi

        # Find all files in the package that would be stowed
        find "$package_dir" -type f | while IFS= read -r source_file; do
            # Get relative path from package directory
            local rel_path="${source_file#$package_dir/}"
            local target_file="${HOME}/${rel_path}"

            # Check if target exists and is not already a correct symlink
            if [[ -e "$target_file" ]] && [[ ! -L "$target_file" ]]; then
                local backup_file="${target_file}.bak.${timestamp}"
                log_warn "Backing up: $target_file -> $backup_file"

                if [[ "$DRY_RUN" != true ]]; then
                    mkdir -p "$(dirname "$backup_file")"
                    mv "$target_file" "$backup_file"
                    ((backup_count++))
                fi
            fi
        done
    done < "$core_manifest"

    if [[ "$backup_count" -gt 0 ]]; then
        log_success "Backed up $backup_count file(s)"
    else
        log_info "No files needed backing up"
    fi
}
