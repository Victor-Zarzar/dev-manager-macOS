#!/bin/bash

# ============================================
# Prerequisites Verification
# ============================================

check_prerequisites() {
    print_section "Checking Prerequisites"

    local ok=true

    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "Not running on macOS"
        return 1
    fi
    print_success "Running on macOS ($(get_os_version))"

    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools already installed"
    else
        print_warning "Xcode Command Line Tools not found - triggering the installer"
        xcode-select --install 2>>"$LOG_FILE"
        print_info "A system dialog should have opened. Finish that install, then re-run this script."
        log_action "Triggered Xcode Command Line Tools installer"
        ok=false
    fi

    if [ -d /Applications/Xcode.app ]; then
        local license_status
        license_status=$(sudo xcodebuild -checkFirstLaunchStatus 2>&1)
        if echo "$license_status" | grep -qi "not agreed\|license"; then
            print_warning "Xcode license not yet accepted - run setup.sh option 13 (Configure Xcode)"
        else
            print_success "Xcode license already accepted"
        fi
    else
        print_info "Xcode.app not installed (only Command Line Tools) - that's fine for most CLI development"
    fi

    local free_gb
    free_gb=$(df -g / | tail -1 | awk '{print $4}')
    if [ "${free_gb:-0}" -lt 10 ]; then
        print_warning "Only ${free_gb}GB free on disk - installations below may need more space"
    else
        print_success "Disk space OK (${free_gb}GB free)"
    fi

    log_action "Prerequisites check finished (ok=$ok)"

    [ "$ok" = true ]
}
