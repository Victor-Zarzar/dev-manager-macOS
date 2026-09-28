#!/bin/bash

# ============================================
# Flutter / Dart / FVM Cache Cleaning
# ============================================

clean_flutter_dart() {
    print_section "Cleaning Flutter/Dart/FVM"

    clean_dir_contents "$HOME/.pub-cache/hosted" "Dart pub cache (hosted packages)"

    local fvm_versions_dir="$HOME/fvm/versions"
    [ -d "$fvm_versions_dir" ] || fvm_versions_dir="$HOME/.fvm/versions"

    if [ -d "$fvm_versions_dir" ]; then
        local size
        size=$(get_folder_size "$fvm_versions_dir")
        print_info "FVM has $(format_size "$size") of cached Flutter SDK versions in $fvm_versions_dir"
        print_info "List them with 'fvm list' and remove one with 'fvm remove <version>'"
    else
        print_info "No FVM SDK cache found, skipping"
    fi

    if command_exists flutter && [ -f "./pubspec.yaml" ]; then
        run_command "flutter clean" "Flutter build artifacts cleaned (current directory)"
    elif command_exists flutter; then
        print_info "Not inside a Flutter project (no pubspec.yaml here) - run 'flutter clean' manually inside each project"
    fi

    # DevTools' own small cache
    clean_dir_contents "$HOME/.dart-tool/dartdev/cache" "Dart DevTools cache"
}
