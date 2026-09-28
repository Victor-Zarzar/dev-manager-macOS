#!/bin/bash

# ============================================
# Application Cache Cleaning
# Slack, Discord, Spotify, and other remaining app caches
# ============================================

cleanup_app_caches() {
    print_section "Cleaning App Caches"

    # Slack
    clean_dir_contents "$HOME/Library/Application Support/Slack/Cache" "Slack cache"
    clean_dir_contents "$HOME/Library/Application Support/Slack/Service Worker/CacheStorage" "Slack service worker cache"

    # Discord
    clean_dir_contents "$HOME/Library/Application Support/discord/Cache" "Discord cache"
    clean_dir_contents "$HOME/Library/Application Support/discord/Code Cache" "Discord code cache"
    clean_dir_contents "$HOME/Library/Application Support/discord/GPUCache" "Discord GPU cache"

    # Spotify
    clean_dir_contents "$HOME/Library/Caches/com.spotify.client" "Spotify browser cache"
    clean_dir_contents "$HOME/Library/Application Support/Spotify/PersistentCache" "Spotify persistent cache"

    print_info "Remaining app caches under ~/Library/Caches were already swept by system cleanup (option 4)"
}
