#!/bin/bash

# ============================================
# System Cache Cleaning
# User caches, logs, Xcode DerivedData/Archives, app containers, DNS
# ============================================

clean_user_caches() {
    print_section "Cleaning User Caches"

    if [ -d "$HOME/Library/Caches" ]; then
        local total_kb=0 entry
        for entry in "$HOME"/Library/Caches/*; do
            [ -e "$entry" ] || continue
            total_kb=$((total_kb + $(get_folder_size "$entry")))
            rm -rf "$entry" 2>>"$LOG_FILE"
        done
        print_success "~/Library/Caches cleaned (freed ~$(format_size "$total_kb"))"
        log_action "~/Library/Caches cleaned (~$(format_size "$total_kb") freed)"
        ((TOTAL_INSTALLED++))
    fi
}

clean_diagnostic_reports() {
    print_section "Cleaning Logs & Diagnostic Reports"

    clean_dir_contents "$HOME/Library/Logs" "User logs"
    clean_dir_contents "/Library/Logs/DiagnosticReports" "Diagnostic reports"
    clean_dir_contents "$HOME/Library/Logs/DiagnosticReports" "User diagnostic reports"
}

clean_xcode_derived_data() {
    print_section "Cleaning Xcode Caches"

    clean_dir_contents "$HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData"

    local device_support="$HOME/Library/Developer/Xcode/iOS DeviceSupport"
    if [ -d "$device_support" ]; then
        local size
        size=$(get_folder_size "$device_support")
        print_info "iOS DeviceSupport symbol files: $(format_size "$size") (one folder per iOS version ever connected)"
        clean_dir_contents "$device_support" "iOS DeviceSupport symbol files"
    fi

    local archives="$HOME/Library/Developer/Xcode/Archives"
    if [ -d "$archives" ]; then
        local size
        size=$(get_folder_size "$archives")
        print_warning "Xcode Archives: $(format_size "$size") (your app's .xcarchive builds - needed to re-submit past versions to the App Store)"
        if confirm "Remove all Xcode Archives"; then
            clean_dir_contents "$archives" "Xcode Archives"
        else
            print_info "Skipped: Xcode Archives"
        fi
    fi
}

clean_app_containers() {
    print_section "Cleaning App Sandbox Containers"

    if [ ! -d "$HOME/Library/Containers" ]; then
        print_info "No app containers found, skipping"
        return 0
    fi

    local total_kb=0 container
    for container in "$HOME"/Library/Containers/*/Data/Library/Caches; do
        [ -d "$container" ] || continue
        total_kb=$((total_kb + $(get_folder_size "$container")))
        find "$container" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>>"$LOG_FILE"
    done
    for container in "$HOME"/Library/Containers/*/Data/Library/Logs; do
        [ -d "$container" ] || continue
        total_kb=$((total_kb + $(get_folder_size "$container")))
        find "$container" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>>"$LOG_FILE"
    done

    print_success "App sandbox container Caches/Logs cleaned (freed ~$(format_size "$total_kb"))"
    log_action "App container caches/logs cleaned (~$(format_size "$total_kb") freed)"
    ((TOTAL_INSTALLED++))
}

flush_dns() {
    print_section "Flushing DNS Cache"

    run_command "sudo dscacheutil -flushcache" "DNS cache flushed"
    run_command "sudo killall -HUP mDNSResponder" "mDNSResponder restarted"
}

# Entrypoint used by run_full_maintenance and the menu (option 4)
clean_system_clean() {
    clean_user_caches
    clean_diagnostic_reports
    clean_xcode_derived_data
    clean_app_containers
    flush_dns
}
