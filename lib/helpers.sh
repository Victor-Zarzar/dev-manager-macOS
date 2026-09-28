#!/bin/bash

# ============================================
# Helper Functions (shared by setup.sh and maintenance.sh)
# ============================================

print_header() {
    local free_space
    free_space=$(get_disk_usage)
    local current_date
    current_date=$(date '+%Y-%m-%d %H:%M:%S')
    local username
    username=$(whoami)
    local os_version
    os_version=$(get_os_version)

    echo -e "${GREEN}"
    echo '██████╗ ███████╗██╗   ██╗'
    echo '██╔══██╗██╔════╝██║   ██║'
    echo '██║  ██║█████╗  ██║   ██║'
    echo '██║  ██║██╔══╝  ╚██╗ ██╔╝'
    echo '██████╔╝███████╗ ╚████╔╝ '
    echo '╚═════╝ ╚══════╝  ╚═══╝  '
    echo ''
    echo '███╗   ███╗ █████╗  ██████╗ ██████╗ ███████╗'
    echo '████╗ ████║██╔══██╗██╔════╝██╔═══██╗██╔════╝'
    echo '██╔████╔██║███████║██║     ██║   ██║███████╗'
    echo '██║╚██╔╝██║██╔══██║██║     ██║   ██║╚════██║'
    echo '██║ ╚═╝ ██║██║  ██║╚██████╗╚██████╔╝███████║'
    echo '╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝'
    echo -e "${NC}"
    echo -e "  ${GREEN}──────────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}✦ User:${NC}        $username"
    echo -e "  ${GREEN}✦ System:${NC}      $os_version"
    echo -e "  ${GREEN}✦ Package Mgr:${NC} $PKG_MGR"
    echo -e "  ${GREEN}✦ Free Space:${NC}  $free_space"
    echo -e "  ${GREEN}✦ Date:${NC}        $current_date"
    echo -e "  ${GREEN}──────────────────────────────────────────────────────────${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${PURPLE}$1${NC}"
    echo "────────────────────────────────────────"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Works for both files and directories (macOS `du` needs -s either way)
get_folder_size() {
    local path="$1"
    local size
    if [ -e "$path" ]; then
        size=$(du -sk "$path" 2>/dev/null | awk '{print $1}')
    fi
    echo "${size:-0}"
}

show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%%${NC}" $percentage
}

# macOS df doesn't support --output like Linux's; -h/-H alone give human-readable
# output on BSD df. Do NOT combine -H with -k - macOS's df treats that as an
# explicit 1024-byte block size request and prints the raw block count instead
# of a human-readable string (e.g. "157751296" instead of "150G").
get_disk_usage() {
    df -h / | tail -1 | awk '{print $4}'
}

get_free_kb() {
    df -k / | tail -1 | awk '{print $4}'
}

# ============================================
# Cleaning Helpers (used by maintenance.sh modules)
# ============================================

# Converts a size in KB (as returned by get_folder_size) into a human string.
# ${kb:-0} guards every call site against "integer expression expected" errors
# when a size lookup came back empty (e.g. permission-denied directories).
format_size() {
    local kb="${1:-0}"
    if [ "${kb:-0}" -ge 1048576 ] 2>/dev/null; then
        awk "BEGIN { printf \"%.2f GB\", $kb/1048576 }"
    elif [ "${kb:-0}" -ge 1024 ] 2>/dev/null; then
        awk "BEGIN { printf \"%.2f MB\", $kb/1024 }"
    else
        echo "${kb:-0} KB"
    fi
}

format_bytes() {
    format_size "$1"
}

# Removes the CONTENTS of a directory (keeps the directory itself), reporting freed space.
# Skips silently (with an info line) if the path doesn't exist.
clean_dir_contents() {
    local path="$1"
    local label="$2"

    if [ ! -d "$path" ]; then
        print_info "$label: not found, skipping"
        return 0
    fi

    local size_before freed
    size_before=$(get_folder_size "$path")

    find "$path" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>>"$LOG_FILE"

    freed=$(format_size "$size_before")
    print_success "$label cleaned (freed ~$freed)"
    log_action "$label cleaned (~$freed freed)"
    ((TOTAL_INSTALLED++))
}

# Removes a directory or file entirely, reporting freed space.
# Skips silently (with an info line) if the path doesn't exist.
clean_path() {
    local path="$1"
    local label="$2"

    if [ ! -e "$path" ]; then
        print_info "$label: not found, skipping"
        return 0
    fi

    local size_before freed
    size_before=$(get_folder_size "$path")

    rm -rf "$path" 2>>"$LOG_FILE"

    freed=$(format_size "$size_before")
    print_success "$label cleaned (freed ~$freed)"
    log_action "$label cleaned (~$freed freed)"
    ((TOTAL_INSTALLED++))
}

# Same as clean_path, but only runs after an explicit y/N confirmation -
# used for destructive/irreversible cleanups (Xcode Archives, node_modules, etc.)
clean_path_confirm() {
    local path="$1"
    local label="$2"
    local prompt="${3:-Remove $label?}"

    if [ ! -e "$path" ]; then
        print_info "$label: not found, skipping"
        return 0
    fi

    if confirm "$prompt"; then
        clean_path "$path" "$label"
    else
        print_info "Skipped: $label"
    fi
}

# ============================================
# macOS version detection
# ============================================
get_os_version() {
    if command_exists sw_vers; then
        echo "macOS $(sw_vers -productVersion) ($(uname -m))"
    else
        echo "Unknown macOS version"
    fi
}

# Returns 0 if the command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Simple yes/no confirmation prompt. Returns 0 for yes, 1 for no.
confirm() {
    local prompt="${1:-Are you sure?} (y/N): "
    local response
    read -r -p "$prompt" response
    [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================
# Command Execution Helper
# ============================================

run_command() {
    local cmd="$1"
    local msg="$2"
    local output

    echo -e "${YELLOW}→${NC} Executing: $cmd"
    if output=$(eval "$cmd" 2>&1); then
        echo "$output" >> "$LOG_FILE"
        print_success "$msg"
        log_action "$msg"
        ((TOTAL_INSTALLED++))
        return 0
    else
        echo "$output" >> "$LOG_FILE"
        print_error "Failed: $msg (see $LOG_FILE)"
        log_action "FAILED: $msg"
        echo -e "${RED}--- Last lines of output ---${NC}"
        echo "$output" | tail -n 10
        echo -e "${RED}-----------------------------${NC}"
        return 1
    fi
}

# Quiet variant - no "Executing: ..." line, for frequent/noisy commands.
run_quiet() {
    local cmd="$1"
    local msg="$2"
    local output

    if output=$(eval "$cmd" 2>&1); then
        echo "$output" >> "$LOG_FILE"
        print_success "$msg"
        log_action "$msg"
        ((TOTAL_INSTALLED++))
        return 0
    else
        echo "$output" >> "$LOG_FILE"
        print_error "Failed: $msg (see $LOG_FILE)"
        log_action "FAILED: $msg"
        return 1
    fi
}
