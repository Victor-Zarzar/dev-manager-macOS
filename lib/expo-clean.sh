#!/bin/bash

# ============================================
# Expo & React Native Cache Cleaning
# ============================================

clean_expo_react_native() {
    print_section "Cleaning Expo & React Native"

    clean_dir_contents "$HOME/.expo/cache" "Expo CLI cache"
    clean_dir_contents "$HOME/.eas" "EAS CLI cache"

    if command_exists watchman; then
        run_command "watchman watch-del-all" "Watchman watches cleared"
    else
        print_info "Watchman not installed, skipping"
    fi

    clean_dir_contents "/tmp/metro-cache" "Metro bundler cache"
    for d in /tmp/haste-map-metro-*; do
        [ -e "$d" ] || continue
        clean_path "$d" "Metro haste map cache ($d)"
    done

    if [ -d "$HOME/Projects" ]; then
        local build_dirs
        build_dirs=$(find "$HOME/Projects" -maxdepth 5 -type d -path "*/android/app/build" 2>/dev/null)
        if [ -n "$build_dirs" ]; then
            print_warning "React Native Android build artifacts found:"
            echo "$build_dirs"
            if confirm "Remove all of these android/app/build directories"; then
                while IFS= read -r dir; do
                    clean_path "$dir" "Android build artifacts ($dir)"
                done <<< "$build_dirs"
            else
                print_info "Skipped: React Native Android build artifacts"
            fi
        fi
    fi
}
