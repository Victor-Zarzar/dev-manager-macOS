#!/bin/bash

# ============================================
# System Assets Cleaning
# AssetsV2 / iWork Templates, iCloud CloudKit cache, Spotlight
# ============================================

clean_system_assets() {
    print_section "Cleaning System Assets"

    # System-wide downloadable asset cache (iWork templates, dictionaries, etc.)
    # Re-downloaded automatically by macOS/iWork apps when actually needed.
    for dir in /Library/Assets/com_apple_MobileAsset_*; do
        [ -d "$dir" ] || continue
        clean_dir_contents "$dir" "System asset cache ($(basename "$dir"))"
    done

    clean_dir_contents "$HOME/Library/Caches/CloudKit" "iCloud CloudKit cache"
    clean_dir_contents "$HOME/Library/Application Support/CloudDocs/session/db" "iCloud Drive session cache"

    if confirm "Rebuild the Spotlight index for / (search will be temporarily unavailable)"; then
        run_command "sudo mdutil -E /" "Spotlight index rebuild triggered"
    else
        print_info "Skipped: Spotlight index rebuild"
    fi
}
