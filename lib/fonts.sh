#!/bin/bash

# ============================================
# Font Installation
# ============================================

install_fonts() {
    print_section "Installing Fonts"

    # homebrew/cask-fonts was merged into the main homebrew/cask tap, so this
    # installs straight from core casks on any reasonably recent Homebrew.
    brew_cask_install "font-jetbrains-mono-nerd-font" "JetBrains Mono Nerd Font"
}
