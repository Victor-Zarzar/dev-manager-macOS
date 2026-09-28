#!/bin/bash

# ============================================
# Node.js Ecosystem Cache Cleaning
# NPM/NVM, Bun, PNPM, Yarn (Classic & Berry), Volta, Turbo, orphan node_modules
# ============================================

clean_npm_nvm() {
    print_section "Cleaning NPM/NVM"

    if command_exists npm; then
        run_command "npm cache clean --force" "NPM cache cleaned"
    else
        print_info "NPM not found, skipping npm cache"
    fi

    clean_dir_contents "$HOME/.nvm/.cache" "NVM download cache"
}

clean_bun() {
    print_section "Cleaning Bun"

    if [ ! -d "$HOME/.bun" ]; then
        print_info "Bun not installed, skipping"
        return 0
    fi

    clean_dir_contents "$HOME/.bun/install/cache" "Bun install cache"
    clean_dir_contents "$HOME/.bun/install/global/cache" "Bun global package cache"

    if [ -d "$HOME/.bun/logs" ]; then
        find "$HOME/.bun/logs" -type f -mtime +7 -delete 2>>"$LOG_FILE"
        print_success "Bun logs older than 7 days removed"
        log_action "Bun old logs removed"
        ((TOTAL_INSTALLED++))
    fi
}

clean_pnpm() {
    print_section "Cleaning PNPM"

    if command_exists pnpm; then
        run_command "pnpm store prune" "PNPM store pruned"
    else
        print_info "PNPM not found, skipping"
    fi
}

clean_yarn() {
    print_section "Cleaning Yarn"

    if command_exists yarn; then
        run_command "yarn cache clean" "Yarn Classic cache cleaned"
    else
        print_info "Yarn not found, skipping"
    fi

    # Yarn Berry's global cache
    clean_dir_contents "$HOME/Library/Caches/Yarn" "Yarn Berry global cache"
}

clean_volta() {
    print_section "Cleaning Volta"

    if [ ! -d "$HOME/.volta" ]; then
        print_info "Volta not installed, skipping"
        return 0
    fi

    clean_dir_contents "$HOME/.volta/tmp" "Volta temporary downloads"
    clean_dir_contents "$HOME/Library/Caches/volta" "Volta cache"
}

clean_turbo() {
    print_section "Cleaning Turborepo Cache"

    if [ -d "$HOME/.turbo" ]; then
        if confirm "Remove the global Turborepo cache (~/.turbo)"; then
            clean_path "$HOME/.turbo" "Global Turbo cache"
        else
            print_info "Skipped: global Turbo cache"
        fi
    else
        print_info "No global Turbo cache found"
    fi

    if [ -d "$HOME/Projects" ]; then
        local project_caches
        project_caches=$(find "$HOME/Projects" -maxdepth 4 -type d -name ".turbo" 2>/dev/null)
        if [ -n "$project_caches" ]; then
            print_warning "Found per-project .turbo caches:"
            echo "$project_caches"
            if confirm "Remove all of these"; then
                while IFS= read -r dir; do
                    clean_path "$dir" "Project Turbo cache ($dir)"
                done <<< "$project_caches"
            else
                print_info "Skipped: per-project Turbo caches"
            fi
        fi
    fi
}

clean_orphan_node_modules() {
    print_section "Scanning for Orphaned node_modules"

    [ -d "$HOME/Projects" ] || { print_info "~/Projects not found, skipping"; return 0; }

    local orphans
    orphans=$(find "$HOME/Projects" -maxdepth 5 -type d -name "node_modules" -mtime +30 2>/dev/null)

    if [ -z "$orphans" ]; then
        print_info "No node_modules older than 30 days found under ~/Projects"
        return 0
    fi

    local total_kb=0
    print_warning "node_modules folders untouched for 30+ days:"
    while IFS= read -r dir; do
        local size
        size=$(get_folder_size "$dir")
        total_kb=$((total_kb + size))
        echo "  $dir ($(format_size "$size"))"
    done <<< "$orphans"

    print_info "Total: $(format_size "$total_kb")"

    if confirm "Delete all of these node_modules folders"; then
        while IFS= read -r dir; do
            clean_path "$dir" "node_modules ($dir)"
        done <<< "$orphans"
    else
        print_info "Skipped: orphaned node_modules"
    fi
}

# Entrypoint used by run_full_maintenance and the menu (option 10)
clean_system_nodejs() {
    clean_npm_nvm
    clean_bun
    clean_pnpm
    clean_yarn
    clean_volta
    clean_turbo
    clean_orphan_node_modules
}
