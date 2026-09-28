#!/bin/bash

# ============================================
# Directory Setup
# ============================================

setup_directories() {
    print_section "Setting Up Directories"

    local dirs=(
        "$HOME/Projects"
        "$HOME/Documents"
        "$HOME/Downloads/Installers"
    )

    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_info "Directory already exists: $dir"
        else
            if mkdir -p "$dir"; then
                print_success "Directory created: $dir"
                ((TOTAL_INSTALLED++))
            else
                print_error "Failed to create directory: $dir"
            fi
        fi
    done

    log_action "Directories configured"
}
