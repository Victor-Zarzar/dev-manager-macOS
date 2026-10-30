#!/bin/bash

# ============================================
# Development Tools
# ============================================

install_git() {
    print_section "Installing Git"
    brew_install "git" "Git"
}

install_development_tools() {
    print_section "Installing Development Tools"

    install_git
    brew_install "nvm" "NVM (Node Version Manager)"
    brew_install "pnpm" "PNPM"
    brew_install "cocoapods" "CocoaPods"
    brew_install "nginx" "Nginx"
    brew_install "nmap" "Nmap"
    brew_install "openssh" "OpenSSH"
    brew_install "openjdk@21" "OpenJDK 21"
    brew_install "kubectl" "kubectl"
    brew_install "minikube" "Minikube"
    brew_install "derailed/k9s/k9s" "k9s"
    brew_install "mas" "mas (Mac App Store CLI)"
    brew_install "mackup" "Mackup (app settings backup)"
    brew_install "ffmpeg" "FFmpeg"

    # Bun's own official tap, per upstream install instructions
    if command_exists bun; then
        print_info "Bun already installed ($(bun --version))"
    else
        brew_install "oven-sh/bun/bun" "Bun"
    fi

    local shell_rc="$HOME/.zshrc"
    if ! grep -q 'NVM_DIR' "$shell_rc" 2>/dev/null; then
        {
            echo ''
            echo '# NVM (added by dev-manager-macos)'
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"'
        } >> "$shell_rc"
    fi

    print_info "OpenJDK 21 needs a symlink to be picked up system-wide:"
    print_info "  sudo ln -sfn \$(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk"
}
