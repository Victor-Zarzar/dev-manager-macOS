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

    if command_exists firebase; then
        print_info "Firebase CLI already installed ($(firebase --version))"
    else
        run_command "curl -sL https://firebase.tools | bash" "Firebase CLI installed"
    fi

    print_info "Start services with 'brew services start mysql|redis|postgresql@16' when needed"
}
