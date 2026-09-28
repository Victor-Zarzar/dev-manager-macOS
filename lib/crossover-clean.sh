#!/bin/bash

# ============================================
# CrossOver Cleaning
# ============================================

clean_crossover() {
    print_section "Cleaning CrossOver"

    if [ ! -d "$HOME/Library/Application Support/CrossOver" ] && [ ! -d "/Applications/CrossOver.app" ]; then
        print_info "CrossOver not installed, skipping"
        return 0
    fi

    clean_dir_contents "$HOME/Library/Caches/com.codeweavers.CrossOver" "CrossOver cache"
    clean_dir_contents "$HOME/Library/Logs/CrossOver" "CrossOver logs"

    local bottles_dir="$HOME/Library/Application Support/CrossOver/Bottles"
    if [ -d "$bottles_dir" ]; then
        local size
        size=$(get_folder_size "$bottles_dir")
        print_warning "CrossOver bottles (Windows app data/prefixes) total $(format_size "$size") in $bottles_dir"
        print_info "Bottles contain installed Windows apps and their data - not removed automatically"
        print_info "Review and remove specific bottles yourself if you no longer need them"
    fi
}
