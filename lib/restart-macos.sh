#!/bin/bash

# ============================================
# System Restart (macOS)
# ============================================

restart_macos() {
    print_section "Restart macOS"

    if ! confirm "This will restart your Mac now. Continue"; then
        print_info "Restart cancelled"
        return 0
    fi

    log_action "System restart requested by user"
    print_warning "Restarting in 5 seconds - press Ctrl+C to cancel"

    for i in 5 4 3 2 1; do
        echo -ne "${YELLOW}$i...${NC} "
        sleep 1
    done
    echo ""

    print_info "Restarting..."
    sudo shutdown -r now
}
