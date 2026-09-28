#!/bin/bash

# ============================================
# macOS Maintenance & Cleaner
# Main Entry Point
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/colors.sh"
source "$LIB_DIR/helpers.sh"
source "$LIB_DIR/system.sh"
source "$LIB_DIR/system-update.sh"
source "$LIB_DIR/ios-clean.sh"
source "$LIB_DIR/android-clean.sh"
source "$LIB_DIR/node-clean.sh"
source "$LIB_DIR/flutter-clean.sh"
source "$LIB_DIR/system-clean.sh"
source "$LIB_DIR/docker-clean.sh"
source "$LIB_DIR/storage-optimize.sh"
source "$LIB_DIR/restart-macos.sh"
source "$LIB_DIR/crossover-clean.sh"
source "$LIB_DIR/expo-clean.sh"
source "$LIB_DIR/devtools-clean.sh"
source "$LIB_DIR/assets-clean.sh"
source "$LIB_DIR/browser-clean.sh"
source "$LIB_DIR/ide-clean.sh"
source "$LIB_DIR/apps-clean.sh"

LOG_FILE="$HOME/dev_cleaner_macOS_$(date +%Y%m%d_%H%M%S).log"
TOTAL_INSTALLED=0

# ============================================
# Main Menu
# ============================================

show_menu() {
    clear
    print_header
    echo "1)  Run complete maintenance"
    echo "2)  Update system and Homebrew"
    echo "3)  Clean update cache"
    echo "4)  Clean system (caches, logs, Xcode, DNS)"
    echo "5)  Clean system assets (AssetsV2, iCloud, Spotlight)"
    echo "6)  Optimize storage"
    echo "7)  Clean iOS simulator"
    echo "8)  Clean iOS firmwares (IPSW)"
    echo "9)  Clean Android Studio & Emulator"
    echo "10) Clean Node.js (NPM, PNPM, Bun, Yarn, Volta, Turbo)"
    echo "11) Clean Flutter / Dart / FVM"
    echo "12) Clean Expo & React Native"
    echo "13) Clean dev tools (Homebrew, CocoaPods, Ruby, Python)"
    echo "14) Clean Docker"
    echo "15) Clean CrossOver cache"
    echo "16) Clean browser caches"
    echo "17) Clean IDE caches (JetBrains, VSCode, Zed Editor)"
    echo "18) Clean app caches (Slack, Discord, Spotify...)"
    echo "19) View action log"
    echo "20) Restart macOS"
    echo "0)  Exit"
    echo ""
    echo -n "Choose an option: "
}

run_full_maintenance() {
    local initial_kb final_kb net_kb
    initial_kb=$(get_free_kb)

    print_header
    echo -e "${YELLOW}Starting complete maintenance...${NC}\n"

    update_system
    clean_software_update_cache
    clean_system_clean
    clean_system_assets
    clean_ios_simulator
    clean_ios_ipsw
    clean_android_studio
    clean_system_nodejs
    clean_flutter_dart
    clean_expo_react_native
    clean_system_devtools
    optimize_storage
    clean_docker
    clean_crossover
    cleanup_browser_caches
    cleanup_ide_caches
    cleanup_app_caches

    final_kb=$(get_free_kb)
    net_kb=$((final_kb - initial_kb))

    echo ""
    print_section "Maintenance Summary"
    echo -e "${GREEN}Total operations completed:${NC} $TOTAL_INSTALLED"
    echo -e "${GREEN}Net free space change:${NC} $(format_size "$net_kb") (includes package updates, so this can be negative)"
    echo -e "${GREEN}Log file:${NC} $LOG_FILE"
    echo ""
    print_success "Maintenance complete!"
    print_warning "System restart recommended"
    echo ""

    log_action "Complete maintenance finished - Total operations: $TOTAL_INSTALLED"
}

# ============================================
# Main Loop
# ============================================

main() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is for macOS only!"
        exit 1
    fi

    touch "$LOG_FILE"
    detect_os
    log_action "Starting maintenance script"

    while true; do
        show_menu
        read -r option

        case $option in
            1) run_full_maintenance ;;
            2) update_system ;;
            3) clean_software_update_cache ;;
            4) clean_system_clean ;;
            5) clean_system_assets ;;
            6) optimize_storage ;;
            7) clean_ios_simulator ;;
            8) clean_ios_ipsw ;;
            9) clean_android_studio ;;
            10) clean_system_nodejs ;;
            11) clean_flutter_dart ;;
            12) clean_expo_react_native ;;
            13) clean_system_devtools ;;
            14) clean_docker ;;
            15) clean_crossover ;;
            16) cleanup_browser_caches ;;
            17) cleanup_ide_caches ;;
            18) cleanup_app_caches ;;
            19) cat "$LOG_FILE" | less ;;
            20) restart_macos ;;
            0)
                print_success "Goodbye!"
                log_action "Script finished"
                exit 0
                ;;
            *)
                print_error "Invalid option!"
                ;;
        esac

        echo ""
        read -p "Press ENTER to continue..."
    done
}

main
