#!/bin/bash

# ============================================
# Shell & Terminal Tools
# ============================================

install_shell_tools() {
    print_section "Installing Shell Tools"

    brew_cask_install "iterm2" "iTerm2"
    brew_install "starship" "Starship prompt"
    brew_install "zsh-autosuggestions" "Zsh Autosuggestions"
    brew_install "eza" "eza (modern ls)"
    brew_install "zoxide" "zoxide (smarter cd)"
    brew_install "bat" "bat (cat with syntax highlighting)"

    local shell_rc="$HOME/.zshrc"
    [ -f "$shell_rc" ] || touch "$shell_rc"

    if ! grep -q "starship init zsh" "$shell_rc" 2>/dev/null; then
        {
            echo ''
            echo '# Starship prompt (added by dev-manager-macos)'
            echo 'eval "$(starship init zsh)"'
        } >> "$shell_rc"
    fi

    if ! grep -q "zoxide init zsh" "$shell_rc" 2>/dev/null; then
        {
            echo ''
            echo '# zoxide (added by dev-manager-macos)'
            echo 'eval "$(zoxide init zsh)"'
        } >> "$shell_rc"
    fi

    if command_exists brew && ! grep -q "zsh-autosuggestions.zsh" "$shell_rc" 2>/dev/null; then
        local autosuggest_path
        autosuggest_path="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        {
            echo ''
            echo '# zsh-autosuggestions (added by dev-manager-macos)'
            echo "source $autosuggest_path"
        } >> "$shell_rc"
    fi

    print_info "Restart your terminal (or 'source ~/.zshrc') to load the new prompt and integrations"
}
