#!/bin/bash

# ============================================
# Storage Optimization
# ============================================

optimize_storage() {
    print_section "Optimizing Storage"

    if [ -d "$HOME/Downloads" ]; then
        local old_count
        old_count=$(find "$HOME/Downloads" -maxdepth 1 -type f -mtime +30 2>/dev/null | wc -l | tr -d ' ')
        if [ "${old_count:-0}" -gt 0 ]; then
            find "$HOME/Downloads" -maxdepth 1 -type f -mtime +30 -delete 2>>"$LOG_FILE"
            print_success "$old_count file(s) older than 30 days removed from ~/Downloads"
            log_action "$old_count old downloads removed"
            ((TOTAL_INSTALLED++))
        else
            print_info "No downloads older than 30 days found"
        fi
    fi

    if [ -d "$HOME/.Trash" ]; then
        clean_dir_contents "$HOME/.Trash" "Trash"
    fi

    if command_exists tmutil; then
        local snapshots
        snapshots=$(tmutil listlocalsnapshots / 2>/dev/null | grep "com.apple.TimeMachine" | wc -l | tr -d ' ')
        if [ "${snapshots:-0}" -gt 0 ]; then
            run_command "sudo tmutil thinlocalsnapshots / 999999999999 4" "$snapshots local Time Machine snapshot(s) thinned"
        else
            print_info "No local Time Machine snapshots found"
        fi
    fi

    clean_dir_contents "$HOME/Library/Containers/com.apple.Photos/Data/Library/Caches" "Photos app cache"

    log_action "Storage optimization finished"
}
