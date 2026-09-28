#!/bin/bash

# ============================================
# Python Tools
# ============================================

install_python_tools() {
    print_section "Installing Python Tools"

    brew_install "pyenv" "Pyenv"
    brew_install "virtualenv" "Virtualenv"

    local shell_rc="$HOME/.zshrc"
    if ! grep -q "pyenv init" "$shell_rc" 2>/dev/null; then
        {
            echo ''
            echo '# Pyenv (added by dev-manager-macos)'
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init -)"'
        } >> "$shell_rc"
    fi

    print_info "Install FastAPI, Uvicorn, and Alembic with pip inside your virtualenvs"
}
