#!/bin/bash

# ============================================
# Xcode Configuration
# ============================================

# Set to true once Xcode.app has been pointed at + license accepted + first launch
# done in this run, so we don't repeat it needlessly.
XCODE_CONFIGURED=false

configure_xcode() {
    print_section "Configuring Xcode"

    if ! xcode-select -p &>/dev/null; then
        print_warning "Xcode Command Line Tools not installed - run setup.sh option 2 first"
        return 1
    fi

    if [ -d /Applications/Xcode.app ]; then
        local ok=true
        run_command "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" "Developer directory pointed at Xcode.app" || ok=false
        run_command "sudo xcodebuild -license accept" "Xcode license accepted" || ok=false
        run_command "sudo xcodebuild -runFirstLaunch" "Xcode first-launch components installed" || ok=false
        [ "$ok" = true ] && XCODE_CONFIGURED=true
    else
        print_info "Xcode.app not found in /Applications - only Command Line Tools are configured"
        print_info "Install Xcode from the Mac App Store for iOS Simulator/full toolchain support"
    fi

    log_action "Xcode configuration finished"
}

# Accepts the license / finishes first launch as soon as Xcode.app exists.
# Called right at the start (prerequisites) and right after Xcode is installed
# from the App Store, so that every later brew command (pyenv, fvm, android-studio...)
# doesn't fail with "You have not agreed to the Xcode license".
# No-op if Xcode.app isn't there yet or was already configured in this run.
ensure_xcode_ready() {
    [ -d /Applications/Xcode.app ] || return 0
    [ "$XCODE_CONFIGURED" = true ] && return 0
    configure_xcode
}
