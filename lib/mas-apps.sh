#!/bin/bash

# ============================================
# Mac App Store Applications (via mas)
# ============================================
#
# Apps that only exist on the Mac App Store (or that you prefer to get from
# there). Format: "APP_STORE_ID|Display name|heavy"
#   - heavy = ask for confirmation first (multi-GB download); omit it otherwise.
#
# To add a new app: run `mas search <name>` (or `mas list` for apps you already
# have) to find its ID and append a line below.

MAS_APPS=(
    "1168254295|AmorphousDiskMark"
    "425264550|Blackmagic Disk Speed Test"
    "1466185689|Blackmagic RAW Speed Test"
    "571213070|DaVinci Resolve|heavy"
    "640199958|Developer"
    "682658836|GarageBand|heavy"
    "1435127111|KeePassium"
    "899247664|TestFlight"
    "1450874784|Transporter"
    "1278508951|Trello"
    "6745342698|uBlock Origin Lite"
    "1494451650|VN"
    "310633997|WhatsApp"
    "497799835|Xcode|heavy"
    "1475387142|Tailscale"
)

# Returns 0 if the app is already installed: either mas knows it, or an app
# bundle with that name already sits in /Applications (installed by hand, or a
# system-protected app mas can't touch - e.g. it fails writing the receipt with
# "Operation not permitted").
mas_is_installed() {
    local id="$1"
    local name="$2"
    mas list 2>/dev/null | awk '{print $1}' | grep -qx "$id" && return 0
    [ -n "$name" ] && [ -d "/Applications/$name.app" ] && return 0
    return 1
}

# Install one App Store app if not already installed
mas_install() {
    local id="$1"
    local desc="$2"

    if mas_is_installed "$id" "$desc"; then
        print_info "$desc already installed"
        return 0
    fi

    if ! run_command "mas install $id" "$desc installed (App Store)"; then
        print_warning "If this keeps failing: make sure you're signed in to the App Store app and that '$desc' is already in your purchased/downloaded list (Apple ID)."
        return 1
    fi
}

install_mas_apps() {
    print_section "Installing Mac App Store Applications"

    # mas itself is installed in dev-tools.sh; bootstrap it here if someone
    # runs this option on its own.
    if ! command_exists mas; then
        brew_install "mas" "mas (Mac App Store CLI)" || return 1
    fi

    print_info "mas can't sign in for you - open the App Store app and log in with your Apple ID first."

    local entry id name heavy
    for entry in "${MAS_APPS[@]}"; do
        IFS='|' read -r id name heavy <<< "$entry"

        if [ "$heavy" = "heavy" ] && ! mas_is_installed "$id" "$name"; then
            if ! confirm "$name is a large download. Install it now?"; then
                print_info "Skipped: $name"
                continue
            fi
        fi

        mas_install "$id" "$name"
    done

    # Xcode just landed? Accept its license + first launch NOW, before any later
    # brew step (pyenv, fvm, android-studio...) trips over the unaccepted license.
    ensure_xcode_ready

    log_action "Mac App Store apps step finished"
}
