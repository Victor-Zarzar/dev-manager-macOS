#!/bin/bash

# ============================================
# Android Studio & Emulator Cache Cleaning
# ============================================

clean_android_studio() {
    print_section "Cleaning Android Studio & Emulator"

    if [ -d "$HOME/.android/avd" ]; then
        for avd_cache in "$HOME"/.android/avd/*/cache; do
            [ -d "$avd_cache" ] || continue
            clean_dir_contents "$avd_cache" "AVD cache ($(basename "$(dirname "$avd_cache")"))"
        done
    else
        print_info "No AVDs found, skipping emulator caches"
    fi

    clean_dir_contents "$HOME/.android/cache" "Android general cache"
    clean_dir_contents "$HOME/.android/build-cache" "Android build cache"

    # Android Studio's own caches/logs on macOS
    for cache_dir in "$HOME"/Library/Caches/Google/AndroidStudio*; do
        [ -d "$cache_dir" ] || continue
        clean_dir_contents "$cache_dir" "Android Studio cache ($(basename "$cache_dir"))"
    done

    for support_dir in "$HOME"/Library/Application\ Support/Google/AndroidStudio*; do
        [ -d "$support_dir" ] || continue
        clean_dir_contents "$support_dir/caches" "Android Studio IDE cache ($(basename "$support_dir"))"
    done

    for log_dir in "$HOME"/Library/Logs/Google/AndroidStudio*; do
        [ -d "$log_dir" ] || continue
        clean_path "$log_dir" "Android Studio logs ($(basename "$log_dir"))"
    done

    if [ -d "$HOME/.gradle/caches" ]; then
        local gradle_size
        gradle_size=$(get_folder_size "$HOME/.gradle/caches")
        print_info "Gradle cache: $(format_size "$gradle_size") - will rebuild automatically on next build"
        clean_dir_contents "$HOME/.gradle/caches" "Gradle cache"
        clean_dir_contents "$HOME/.gradle/wrapper/dists" "Gradle wrapper distributions"
    fi

    clean_dir_contents "$HOME/.gradle/daemon" "Gradle daemon logs"
}
