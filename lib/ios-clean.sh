#!/bin/bash

# ============================================
# iOS Simulator & Firmware (IPSW) Cleaning
# ============================================

clean_ios_simulator() {
    print_section "Cleaning iOS Simulator"

    if ! command_exists xcrun; then
        print_info "Xcode command-line tools not found, skipping simulator cleanup"
        return 0
    fi

    run_command "xcrun simctl delete unavailable" "Unavailable/orphaned simulator devices removed"
    clean_dir_contents "$HOME/Library/Developer/CoreSimulator/Caches" "CoreSimulator cache"

    print_info "Old device symbol files also live in 'iOS DeviceSupport' - cleaned separately in system cleanup"
}

clean_ios_ipsw() {
    print_section "Cleaning iOS Firmware Files (IPSW)"

    local ipsw_dirs=(
        "$HOME/Library/iTunes/iPhone Software Updates"
        "$HOME/Library/iTunes/iPad Software Updates"
        "$HOME/Library/Application Support/MobileSync/Software Updates"
    )

    local found=false
    for dir in "${ipsw_dirs[@]}"; do
        [ -d "$dir" ] || continue
        local count
        count=$(find "$dir" -maxdepth 1 -iname "*.ipsw" 2>/dev/null | wc -l | tr -d ' ')
        if [ "${count:-0}" -gt 0 ]; then
            found=true
            print_warning "$count IPSW file(s) found in $dir (each 3-11 GB)"
            if confirm "Delete these IPSW files"; then
                clean_dir_contents "$dir" "IPSW firmware files ($dir)"
            else
                print_info "Skipped: $dir"
            fi
        fi
    done

    if [ "$found" = false ]; then
        print_info "No cached IPSW firmware files found"
    fi
}
