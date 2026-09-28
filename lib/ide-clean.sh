#!/bin/bash

# ============================================
# IDE Cache Cleaning
# JetBrains IDEs, Visual Studio Code, Zed Editor
# ============================================

cleanup_ide_caches() {
    print_section "Cleaning IDE Caches"

    # JetBrains IDEs (IntelliJ IDEA, WebStorm, PyCharm, GoLand, CLion, DataGrip, RubyMine, Rider,
    # and its own Android Studio caches - AVD/Gradle already handled in android-clean.sh)
    for dir in "$HOME"/Library/Caches/JetBrains/*; do
        [ -d "$dir" ] || continue
        clean_dir_contents "$dir" "JetBrains cache ($(basename "$dir"))"
    done

    # Visual Studio Code
    clean_dir_contents "$HOME/Library/Application Support/Code/Cache" "VS Code cache"
    clean_dir_contents "$HOME/Library/Application Support/Code/CachedData" "VS Code cached data"
    clean_dir_contents "$HOME/Library/Application Support/Code/CachedExtensions" "VS Code cached extensions"
    clean_dir_contents "$HOME/Library/Application Support/Code/Code Cache" "VS Code code cache"

    # Zed Editor
    clean_dir_contents "$HOME/Library/Caches/dev.zed.Zed" "Zed Editor cache"
}
