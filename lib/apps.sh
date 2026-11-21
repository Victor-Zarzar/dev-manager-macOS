#!/bin/bash

# ============================================
# Application Installation (GUI apps via Homebrew Cask)
# ============================================

install_apps() {
    print_section "Installing Applications"

    # Editors / browsers
    brew_cask_install "zed" "Zed Editor"
    brew_cask_install "sublime-text" "Sublime Text"
    brew_cask_install "firefox" "Firefox"
    brew_cask_install "google-chrome" "Google Chrome"

    # Communication
    brew_cask_install "telegram" "Telegram"
    brew_cask_install "discord" "Discord"
    brew_cask_install "slack" "Slack"

    # Productivity
    brew_cask_install "notion" "Notion"
    brew_cask_install "onlyoffice" "OnlyOffice"
    brew_cask_install "rectangle" "Rectangle (window manager)"
    brew_cask_install "shottr" "Shottr (screenshots)"
    brew_cask_install "figma" "Figma"
    brew_cask_install "lightcraft" "LightCraft"
    brew_cask_install "filmcraft" "FilmCraft"

    # Security / VPN
    brew_cask_install "protonvpn" "ProtonVPN"
    brew_cask_install "tunnelblick" "Tunnelblick"
    brew_cask_install "cloudflare-warp" "Cloudflare WARP"

    # Utilities
    brew_cask_install "localsend" "LocalSend"
    brew_cask_install "orbstack" "OrbStack (Docker engine)"
    brew_cask_install "omnidisksweeper" "OmniDiskSweeper"
    brew_cask_install "macs-fan-control" "Macs Fan Control"

    # Audio
    brew_cask_install "spotify" "Spotify"

    # Bottles
    brew_cask_install "crossover" "Crossover"
}
