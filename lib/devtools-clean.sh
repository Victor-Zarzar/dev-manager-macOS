#!/bin/bash

# ============================================
# Dev Tools Cleaning: Homebrew, CocoaPods, Ruby, Python
# ============================================

clean_homebrew() {
    print_section "Cleaning Homebrew"

    if ! command_exists brew; then
        print_info "Homebrew not installed, skipping"
        return 0
    fi

    run_command "brew cleanup --prune=all" "Old formula/cask versions and download cache removed"
    run_command "brew autoremove" "Unused dependencies removed"
}

clean_cocoapods() {
    print_section "Cleaning CocoaPods"

    if ! command_exists pod; then
        print_info "CocoaPods not installed, skipping"
        return 0
    fi

    clean_dir_contents "$HOME/Library/Caches/CocoaPods" "CocoaPods download cache"

    if [ -d "$HOME/.cocoapods/repos" ]; then
        if confirm "Remove CocoaPods spec repos (~/.cocoapods/repos - will re-clone on next 'pod install')"; then
            clean_path "$HOME/.cocoapods/repos" "CocoaPods spec repos"
        else
            print_info "Skipped: CocoaPods spec repos"
        fi
    fi
}

clean_ruby() {
    print_section "Cleaning Ruby (rbenv/RVM/gems)"

    if command_exists rbenv; then
        print_info "Installed rbenv Ruby versions:"
        rbenv versions 2>/dev/null | tee -a "$LOG_FILE"
        print_info "Remove ones you no longer need with 'rbenv uninstall <version>'"
    fi

    if command_exists rvm; then
        run_command "rvm cleanup all" "RVM old packages/sources cleaned"
    fi

    if command_exists gem; then
        run_command "gem cleanup" "Old gem versions removed"
    fi

    clean_dir_contents "$HOME/.gem/cache" "Gem download cache"
}

clean_python_toolchain() {
    print_section "Cleaning Python (pyenv/pip/__pycache__)"

    if command_exists pyenv; then
        print_info "Installed pyenv Python versions:"
        pyenv versions 2>/dev/null | tee -a "$LOG_FILE"
        print_info "Remove ones you no longer need with 'pyenv uninstall <version>'"
    fi

    if command_exists pip3; then
        run_command "pip3 cache purge" "PIP cache purged"
    elif command_exists pip; then
        run_command "pip cache purge" "PIP cache purged"
    fi

    if [ -d "$HOME/Projects" ]; then
        local pycache_dirs
        pycache_dirs=$(find "$HOME/Projects" -maxdepth 6 -type d -name "__pycache__" 2>/dev/null)
        if [ -n "$pycache_dirs" ]; then
            local count
            count=$(echo "$pycache_dirs" | wc -l | tr -d ' ')
            print_info "Found $count __pycache__ folder(s) under ~/Projects"
            while IFS= read -r dir; do
                rm -rf "$dir" 2>>"$LOG_FILE"
            done <<< "$pycache_dirs"
            print_success "$count __pycache__ folder(s) removed"
            log_action "$count __pycache__ folders removed"
            ((TOTAL_INSTALLED++))
        else
            print_info "No __pycache__ folders found under ~/Projects"
        fi
    fi
}

# Entrypoint used by run_full_maintenance and the menu (option 13)
clean_system_devtools() {
    clean_homebrew
    clean_cocoapods
    clean_ruby
    clean_python_toolchain
}
