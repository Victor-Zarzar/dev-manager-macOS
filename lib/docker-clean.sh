#!/bin/bash

# ============================================
# Docker Cleanup (works with OrbStack's Docker engine too)
# ============================================

clean_docker() {
    print_section "Cleaning Docker"

    if ! command_exists docker; then
        print_info "Docker CLI not found (install OrbStack or Docker Desktop), skipping"
        return 0
    fi

    if ! docker info &>/dev/null; then
        print_warning "Docker engine isn't running (start OrbStack/Docker Desktop) - skipping"
        return 0
    fi

    run_command "docker container prune -f" "Stopped containers removed"
    run_command "docker image prune -af" "Unused images removed"
    run_command "docker network prune -f" "Unused networks removed"
    run_command "docker builder prune -af" "Build cache pruned"

    if confirm "Also remove unused Docker volumes (irreversible data loss for unattached volumes)"; then
        run_command "docker volume prune -f" "Unused volumes removed"
    else
        print_info "Skipped: Docker volumes"
    fi

    print_info "Full report: run 'docker system df' to see current disk usage by Docker"
}
