#!/bin/bash

# ============================================
# Flutter & Mobile Development Tools
# ============================================

install_flutter_tools() {
    print_section "Installing Flutter Tools"

    brew_install "leoafarias/fvm/fvm" "FVM (Flutter Version Manager)"
    brew_cask_install "android-studio" "Android Studio"

    print_info "Xcode (for iOS builds) is configured separately - see setup.sh option 13"
    print_info "Use 'fvm install stable && fvm use stable' inside a Flutter project to get started"
}
