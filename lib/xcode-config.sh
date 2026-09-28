#!/bin/bash

# ============================================
# Xcode Configuration
# ============================================

configure_xcode() {
    print_section "Configuring Xcode"

    if ! xcode-select -p &>/dev/null; then
        print_warning "Xcode Command Line Tools not installed - run setup.sh option 2 first"
        return 1
    fi

    if [ -d /Applications/Xcode.app ]; then
        run_command "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" "Developer directory pointed at Xcode.app"
        run_command "sudo xcodebuild -license accept" "Xcode license accepted"
        run_command "sudo xcodebuild -runFirstLaunch" "Xcode first-launch components installed"
    else
        print_info "Xcode.app not found in /Applications - only Command Line Tools are configured"
        print_info "Install Xcode from the Mac App Store for iOS Simulator/full toolchain support"
    fi

    log_action "Xcode configuration finished"
}
