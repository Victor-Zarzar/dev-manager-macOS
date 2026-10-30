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

MOVED_TAPS=(
    "leoafarias/fvm|btwld/fvm"
)

migrate_moved_taps() {
    local entry old new formula
    for entry in "${MOVED_TAPS[@]}"; do
        IFS='|' read -r old new <<< "$entry"

        brew tap 2>/dev/null | grep -qx "$old" || continue

        print_info "Tap $old moved to $new - migrating"
        formula="${old#*/}"   # fvm/fvm -> fvm (formula name equals the tap's repo name here)

        # Installed formula must go first, otherwise brew refuses to untap
        local reinstall=false
        if brew list --formula "$formula" &>/dev/null; then
            reinstall=true
            run_command "brew uninstall --force $formula" "$formula uninstalled (will be reinstalled from $new)"
        fi

        run_command "brew untap --force $old" "Old tap $old removed"
        run_command "brew tap $new" "New tap $new added"

        if [ "$reinstall" = true ]; then
            run_command "brew install $new/$formula" "$formula reinstalled from $new"
        fi
    done
}

update_system() {
    print_section "Updating System & Homebrew"

    run_command "softwareupdate --list" "Checked for macOS system updates (see log for details)"

    if command_exists brew; then
        migrate_moved_taps
        run_command "brew update" "Homebrew formulae/casks index updated"
        run_command "brew upgrade" "Installed formulae upgraded"
        run_command "brew upgrade --cask" "Installed casks upgraded"

        if command_exists mas; then
            run_command "mas upgrade" "Mac App Store apps upgraded"
        fi
    else
        print_warning "Homebrew not installed - run setup.sh option 3 first"
    fi

    log_action "System update finished"
}
