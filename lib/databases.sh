#!/bin/bash

# ============================================
# Database Installation
# ============================================

install_databases() {
    print_section "Installing Databases"

    brew_install "sqlite" "SQLite"
    brew_install "mysql" "MySQL"
    brew_install "redis" "Redis"
    brew_install "postgresql@16" "PostgreSQL"
    brew_install "supabase/tap/supabase" "Supabase CLI"

    # Installed via Homebrew (native arm64). The curl installer (firebase.tools)
    # fetched an x86_64 binary on this machine -> "Bad CPU type in executable".
    if command_exists firebase; then
        local fb_version
        if fb_version=$(firebase --version 2>/dev/null); then
            print_info "Firebase CLI already installed ($fb_version)"
        else
            local fb_path
            fb_path=$(command -v firebase)
            print_warning "Firebase CLI at $fb_path doesn't run (wrong CPU architecture?)"
            if confirm "Remove it and reinstall via Homebrew?"; then
                sudo rm -f "$fb_path" && brew_install "firebase-cli" "Firebase CLI"
            else
                print_info "Skipped: Firebase CLI"
            fi
        fi
    else
        brew_install "firebase-cli" "Firebase CLI"
    fi

    print_info "Start services with 'brew services start mysql|redis|postgresql@16' when needed"
}
