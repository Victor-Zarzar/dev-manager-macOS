#!/bin/bash

# ============================================
# Homebrew Installation & Package Helpers
# ============================================

install_homebrew() {
    print_section "Installing Homebrew"

    if command_exists brew; then
        print_info "Homebrew already installed ($(brew --version | head -n1))"
        PKG_MGR="brew"
        return 0
    fi

    print_info "Running the official Homebrew installer (non-interactive)..."
    print_info "You may be prompted for your macOS account password (sudo) - that prompt is normal."

    # NONINTERACTIVE=1 makes Homebrew's installer skip its "Press RETURN to
    # continue or any other key to abort" prompt. This matters here: run_command
    # captures a command's entire output into a variable before printing anything,
    # which would silently swallow that prompt and make the script look hung while
    # it was actually just waiting for a keypress nobody could see. Running it
    # directly (not through run_command) also means its progress output streams
    # to the terminal live instead of appearing all at once at the end.
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tee -a "$LOG_FILE"
    # A pipeline's exit status is the *last* command's (tee, which almost always
    # succeeds) unless we check PIPESTATUS explicitly - otherwise a failed
    # installer would still be reported as a success below.
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then
        print_success "Homebrew installed"
        log_action "Homebrew installed"
        ((TOTAL_INSTALLED++))
    else
        print_error "Homebrew installation failed (see $LOG_FILE)"
        log_action "FAILED: Homebrew installation"
        return 1
    fi

    # Apple Silicon installs to /opt/homebrew, Intel to /usr/local - shellenv sets
    # PATH/MANPATH/etc. correctly either way for the rest of this run.
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    local shell_rc="$HOME/.zprofile"
    if ! grep -q "brew shellenv" "$shell_rc" 2>/dev/null; then
        {
            echo ''
            echo '# Homebrew (added by dev-manager-macos)'
            if [ -x /opt/homebrew/bin/brew ]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"'
            fi
        } >> "$shell_rc"
        print_info "Added 'brew shellenv' to $shell_rc"
    fi

    PKG_MGR="brew"
}

# Install a Homebrew formula if not already installed
brew_install() {
    local pkg="$1"
    local desc="${2:-$1}"

    if ! command_exists brew; then
        print_error "Homebrew is not installed. Run setup.sh option 3 first."
        return 1
    fi

    if brew list --formula "$pkg" &>/dev/null; then
        print_info "$desc already installed"
        return 0
    fi

    run_command "brew install $pkg" "$desc installed"
}

# Install a Homebrew cask (GUI app) if not already installed
brew_cask_install() {
    local pkg="$1"
    local desc="${2:-$1}"

    if ! command_exists brew; then
        print_error "Homebrew is not installed. Run setup.sh option 3 first."
        return 1
    fi

    if brew list --cask "$pkg" &>/dev/null; then
        print_info "$desc already installed"
        return 0
    fi

    run_command "brew install --cask $pkg" "$desc installed"
}
