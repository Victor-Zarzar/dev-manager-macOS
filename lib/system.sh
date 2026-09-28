#!/bin/bash

# ============================================
# System Configuration Functions (shared)
# ============================================

PKG_MGR="brew"

detect_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is for macOS only!"
        exit 1
    fi

    if ! command_exists brew; then
        PKG_MGR="brew (not installed yet)"
        print_info "Homebrew not found yet - install it first (setup.sh option 3)"
    else
        PKG_MGR="brew"
    fi

    print_info "Detected system: $(get_os_version)"
}

update_system() {
    print_section "Updating System & Homebrew"

    run_command "softwareupdate --list" "Checked for macOS system updates (see log for details)"

    if command_exists brew; then
        run_command "brew update" "Homebrew formulae/casks index updated"
        run_command "brew upgrade" "Installed formulae upgraded"
        run_command "brew upgrade --cask" "Installed casks upgraded"
    else
        print_warning "Homebrew not installed - run setup.sh option 3 first"
    fi

    log_action "System update finished"
}
