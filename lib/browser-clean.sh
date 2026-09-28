#!/bin/bash

# ============================================
# Browser Cache Cleaning
# ============================================

cleanup_browser_caches() {
    print_section "Cleaning Browser Caches"

    # Google Chrome
    clean_dir_contents "$HOME/Library/Caches/Google/Chrome" "Chrome cache"
    clean_dir_contents "$HOME/Library/Application Support/Google/Chrome/Default/Cache" "Chrome profile cache"
    clean_dir_contents "$HOME/Library/Application Support/Google/Chrome/Default/Code Cache" "Chrome code cache"
    clean_dir_contents "$HOME/Library/Application Support/Google/Chrome/Default/GPUCache" "Chrome GPU cache"

    # Safari (cache only - never touches bookmarks/history)
    clean_dir_contents "$HOME/Library/Caches/com.apple.Safari" "Safari cache"

    # Orion Browser
    clean_dir_contents "$HOME/Library/Caches/com.kagi.kagimacOS" "Orion cache"
    clean_dir_contents "$HOME/Library/Application Support/Orion/Defaults/Storage" "Orion offline data"

    # Firefox
    for profile in "$HOME"/Library/Caches/Firefox/Profiles/*; do
        [ -d "$profile" ] || continue
        clean_dir_contents "$profile" "Firefox cache ($(basename "$profile"))"
    done

    # Brave
    clean_dir_contents "$HOME/Library/Caches/BraveSoftware" "Brave cache"

    # Arc
    clean_dir_contents "$HOME/Library/Caches/company.thebrowser.Browser" "Arc cache"

    # Microsoft Edge
    clean_dir_contents "$HOME/Library/Caches/Microsoft Edge" "Edge cache"
}
