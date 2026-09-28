#!/bin/bash

# ============================================
# Software Update Cache Cleaning
# (update_system itself lives in lib/system.sh, shared with setup.sh)
# ============================================

clean_software_update_cache() {
    print_section "Cleaning Software Update Cache"

    clean_dir_contents "/Library/Updates" "macOS Software Update cache"

    if command_exists brew; then
        run_command "brew cleanup -s" "Homebrew download cache cleaned"
    fi
}
